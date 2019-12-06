FROM gcr.io/jenkinsxio/builder-go-maven:2.0.1062-389
USER root
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
