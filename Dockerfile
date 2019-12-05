FROM gcr.io/jenkinsxio/dev-env-base:0.0.468-go-alpine
USER root
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
