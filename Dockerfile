FROM gcr.io/jenkinsxio/builder-go-maven:latest
USER root
ENV JQ_RELEASE_VERSION 1.5
RUN wget https://github.com/stedolan/jq/releases/download/jq-${JQ_RELEASE_VERSION}/jq-linux64 && mv jq-linux64 jq && chmod +x jq && cp jq /usr/bin/jq
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
