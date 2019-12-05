FROM gcr.io/jenkinsxio/dev-env-base:0.0.468-go-alpine
RUN mkdir fossa-dl && \
curl "https://api.github.com/repos/fossas/fossa-cli/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"v([^"]+)".*/\1/' | \
    xargs -I {} curl -fL 'https://github.com/fossas/fossa-cli/releases/download/v'{}'/fossa-cli_'{}'_linux_amd64.tar.gz' | tar xzvC fossa-dl && \
mv fossa-dl/fossa /usr/bin && \
rm -rf fossa-dl
COPY ./jx-app-fossa.sh /
ENTRYPOINT ["/jx-app-fossa.sh"]
