# Container image that runs your code
FROM alpine/helm:3.6.3

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]

RUN wget https://github.com/instrumenta/kubeval/releases/download/v0.16.1/kubeval-linux-amd64.tar.gz \
    && mkdir /kubeval \
    && tar xf kubeval-linux-amd64.tar.gz -C /kubeval \
    && rm -r kubeval-linux-amd64.tar.gz

COPY entrypoint.sh /entrypoint.sh
