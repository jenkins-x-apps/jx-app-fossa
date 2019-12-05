FROM gcr.io/jenkinsxio/dev-env-base:0.0.468-go-alpine
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
