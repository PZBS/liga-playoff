import argparse, copy, logging, sys
from decimal import Decimal

from jfr_playoff.data.info import MatchInfo
from jfr_playoff.generator import PlayoffGenerator
from jfr_playoff.settings import PlayoffSettings


arg_parser = argparse.ArgumentParser(
    description='Check external jfrteamy-playoff sources for team names and carry-over against the JTPO bracket')
output_args = arg_parser.add_mutually_exclusive_group()
output_args.add_argument('-v', '--verbose', action='store_true',
                         help='display info on STDERR')
output_args.add_argument('-vv', '--debug', action='store_true',
                         help='display debug info on STDERR')
arg_parser.add_argument('config_file', metavar='JSON_FILE',
                        help='path to config JSON file',
                        type=str)
arg_parser.add_argument('phase', metavar='PHASE_NUMBER',
                        help='phase number to check',
                        type=int)
arguments = arg_parser.parse_args()

logging.basicConfig(
    level=logging.ERROR,
    format='%(levelname)-8s %(message)s')
logger = logging.getLogger('checks')
logger.setLevel(logging.INFO if arguments.verbose else (
    logging.DEBUG if arguments.debug else logging.WARNING))

phase_no = arguments.phase

settings = PlayoffSettings(arguments.config_file)
generator = PlayoffGenerator(settings)

phases = generator.data.generate_phases()
phases = phases[0:phase_no]
generator.data.grid = phases
generator.data.phases = generator.data.phases[0:phase_no]

carry_over = Decimal(settings.get('page').get(
    'team_boxes', {}).get('auto_carryover', 0.0))

matches = generator.data.fill_match_info()

for match in generator.data.phases[-1]['matches']:
    logger.info('Checking match #%d', match['id'])
    remote_info = matches[match['id']]
    logger.debug('Actual match info: %s', remote_info)

    info_client = MatchInfo(
        match, generator.data.teams,
        generator.data.database,
        generator.data.aliases,
        starting_positions_certain=True,
        auto_carryover=carry_over)

    # test if any external data source returns a team list
    fetched_teams = None
    for client in info_client.clients:
        try:
            fetched_teams = client.fetch_teams(
                copy.deepcopy(remote_info.teams))
        except Exception as e:
            pass
    logger.debug('Teams fetched from external source: %s', fetched_teams)
    if fetched_teams is None:
        if remote_info.running != 0:
            logger.info('Match with pre-set score, skipping checks')
            continue
        else:
            logger.error('External source for match #%d does not exist!', match['id'])
            continue
    del info_client.clients[:] # disable all external data sources
    bracket_info = info_client.get_info()
    logger.debug('Bracket-derived info: %s', bracket_info.__dict__)

    # base data for comparison, derived only from bracket data
    bracket_teams = bracket_info.teams

    # we're using team names from the fully fetched actual bracket,
    # because it's got team aliases resolved
    remote_teams = remote_info.teams

    for team in [0, 1]:
        if remote_teams[team].selected_name != bracket_teams[team].selected_name:
            logger.error('%s team in match #%d mismatch. External: %s, bracket: %s',
                         'Away' if team else 'Home', match['id'],
                         remote_teams[team].selected_name, bracket_teams[team].selected_name)

    if remote_info.running != 0:
        logger.info('Match already started, skipping score check')
    else:
        # if running == 0, "fetched" scores are going to be overridden by auto-carryover
        # we need to validate exactly what's been externally fetched
        for team in [0, 1]:
            if fetched_teams[team].league_carry_over != bracket_teams[team].league_carry_over:
                logger.warning('Score for %s team in match #%d mismatch. External: %s, bracket: %s',
                               'Away' if team else 'Home', match['id'],
                               fetched_teams[team].league_carry_over, bracket_teams[team].league_carry_over)
