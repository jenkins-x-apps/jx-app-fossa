whoami
pwd
env
ls -la
echo $JOB_SPEC | jq 'contains({"type": "postsubmit", "job": "release"})'
IS_RELEASE_BUILD=echo $JOB_SPEC | jq 'contains({"type": "postsubmit", "job": "release"})'
echo $IS_RELEASE_PIPELINE
if [ "$IS_RELEASE_PIPELINE" == "false" ]; then
    mkdir fossa-dl
    curl "https://api.github.com/repos/fossas/fossa-cli/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"v([^"]+)".*/\1/' | \
        xargs -I {} curl -fL 'https://github.com/fossas/fossa-cli/releases/download/v'{}'/fossa-cli_'{}'_linux_amd64.tar.gz' | tar xzvC fossa-dl && \
    mv fossa-dl/fossa /usr/bin && \
    rm -rf fossa-dl
    if [ -f main.go ]; then
        # This is a Go project
        if [ ! -f go.mod ]; then
            # Fossa requires a mod file or lock file
            go mod init
        fi
    fi
    fossa init
    export FOSSA_API_KEY=e8f6249ad76777febbcc6f59b43074b0
    fossa analyze
    fossa test
elif
    echo "Skipping FOSSA scan"
fi