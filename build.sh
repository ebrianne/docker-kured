#!/bin/bash

KURED_RELEASE=$(curl -sX GET "https://api.github.com/repos/weaveworks/kured/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
echo "kured release is v${KURED_RELEASE}"
echo "Building docker container"
docker build --platform linux/amd64,linux/arm64 -t ebrianne/kured:v${KURED_RELEASE} --push .