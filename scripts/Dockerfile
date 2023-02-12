FROM python:2.7
RUN apt-get update && apt-get install -y libxml2-dev libxslt-dev
RUN mkdir -p /app
COPY scripts/jfrteamy-playoff/requirements.txt /app/
RUN pip install -r /app/requirements.txt
RUN mkdir -p /app/src
RUN mkdir -p /app/config
WORKDIR /app/src
