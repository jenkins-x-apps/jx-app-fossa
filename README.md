# jx-app-fossa
This App integrates the FOSSA open source licence compliance service into all builds for a given Jenkins-X installation.

You will require an account with FOSSA and an API Token associated with that account. See https://app.fossa.com/account/settings/integrations/api_tokens

You can use push-only tokens for additional security, if required.

During each build, the FOSSA client will scan your code for licence information and uploads a summary of its findings to the FOSSA service for analysis. It does not upload your code. You can configure the App to scan asynchronously and report issues in your FOSSA control panel or to wait to validate the scan and fail the build if issues are detected.

##Installation
You can install using `jx add app jx-app-fossa`. You will be asked for your FOSSA API token and whether you would like to enable or disable the ability to fail the build for both preview and release builds.

##Uninstall
You can uninstall using `jx delete app jx-app-fossa`
