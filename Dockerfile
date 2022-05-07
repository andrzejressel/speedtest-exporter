##
## Build
##
FROM golang:alpine3.15 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY collector/*.go ./collector/
COPY *.go ./

RUN go build -o /speedtest_exporter

##
## Deploy
##
FROM alpine

WORKDIR /

COPY --from=build /speedtest_exporter /speedtest_exporter

EXPOSE 9876

RUN wget -O /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-$(apk info --print-arch)-linux.tgz" && \
	tar xvfz /tmp/speedtest.tgz -C /usr/local/bin speedtest && \
	rm -rf /tmp/speedtest.tgz

ENTRYPOINT ["/speedtest_exporter"]