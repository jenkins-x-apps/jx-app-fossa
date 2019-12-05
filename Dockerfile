FROM gcr.io/jenkinsxio/dev-env-base:0.0.468-go-alpine
RUN curl https://raw.githubusercontent.com/fossas/fossa-cli/master/install.sh | bash 
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
