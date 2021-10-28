# Container image that runs your code
FROM alpine:3.10

RUN apk add curl
RUN apk add --no-cache wget
RUN wget -O /usr/local/bin/yaml "https://github.com/mikefarah/yq/releases/download/${YAML_BIN_VERSION}/yq_linux_amd64"
# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
