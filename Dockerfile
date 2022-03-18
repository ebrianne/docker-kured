FROM golang:alpine3.13 as build

ARG TARGETOS
ARG TARGETARCH
ARG KURED_RELEASE

RUN apk --no-cache add git alpine-sdk
RUN if [ -z ${KURED_RELEASE+x} ]; then \
	KURED_RELEASE=$(curl -sX GET "https://api.github.com/repos/weaveworks/kured/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    echo "Kured version is $KURED_RELEASE" && \
    cd /tmp && wget "https://github.com/weaveworks/kured/archive/refs/tags/$KURED_RELEASE.zip" && \
    unzip $KURED_RELEASE.zip && \
    cd /tmp/kured-$KURED_RELEASE && \
    GO111MODULE=on go mod vendor && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags "-s -w -X main.version=${KURED_RELEASE}" -o /tmp/kured ./cmd/kured/*.go

FROM alpine:3.15
LABEL name="kured"

ENV TZ="Europe/Berlin"

RUN apk update --no-cache && apk upgrade --no-cache && apk add --no-cache ca-certificates tzdata
COPY --from=build /tmp/kured /usr/bin/kured

ENTRYPOINT ["/usr/bin/kured"]