mkdir fossa-dl
curl "https://api.github.com/repos/fossas/fossa-cli/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"v([^"]+)".*/\1/' | \
    xargs -I {} curl -fL 'https://github.com/fossas/fossa-cli/releases/download/v'{}'/fossa-cli_'{}'_linux_amd64.tar.gz' | tar xzvC fossa-dl && \
mv fossa-dl/fossa /usr/bin && \
rm -rf fossa-dl
if [ ! -f go.mod ]; then
  # Fossa requires a mod file or lock file
  go mod init
fi
fossa init
export FOSSA_API_KEY=e8f6249ad76777febbcc6f59b43074b0
fossa analyze
fossa test
