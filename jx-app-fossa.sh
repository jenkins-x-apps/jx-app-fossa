whoami
pwd
env
ls -la
while getopts k:r:p: option
do
case "${option}"
in
u) FOSSA_API_KEY=${OPTARG};;
d) FOSSA_FAIL_ON_RELEASE=${OPTARG};;
p) FOSSA_FAIL_ON_PREVIEW=${OPTARG};;
esac
done
unset IS_PREVIEW_PIPELINE
unset IS_RELEASE_PIPELINE
# Try and establish what phase of what type of build pipeline we are in
[[ "${PIPELINE_KIND}" == "pullrequest" ]] && [ ! -f .pre-commit-config.yaml ] && IS_PREVIEW_PIPELINE="true" || IS_PREVIEW_PIPELINE="false"
if [[ ${IS_PREVIEW_PIPELINE} == "true" ]] ; then
    echo "Detected Preview pipeline";
fi
[[ "$PIPELINE_KIND" == "release" ]] && [ ! -f .pre-commit-config.yaml ] && IS_RELEASE_PIPELINE="true" || IS_RELEASE_PIPELINE="false"
if [[ ${IS_RELEASE_PIPELINE} == "true" ]] ; then
    echo "Detected Release pipeline";
fi
# Only activate in preview builds or the first stage of a release
if [[ ${IS_PREVIEW_PIPELINE} == "true" ]] || [[ ${IS_RELEASE_PIPELINE} == "true" ]] ; then
    echo "FOSSA is scanning dependencies..."
    echo $IS_PREVIEW_PIPELINE
    echo $IS_RELEASE_PIPELINE
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
    fossa analyze
    fossa test
else
    echo "Skipping FOSSA scan"
fi