# build stage
FROM golang:alpine AS build-env
ADD . /go/src/github.com/karunsiri/clamav-rest/
RUN cd /go/src/github.com/karunsiri/clamav-rest && go build -v

# dockerize stage
FROM alpine
MAINTAINER Karun Siritheerathamrong <karoon.siri@gmail.com>

RUN apk --no-cache add clamav clamav-libunrar \
    && mkdir /run/clamav \
    && chown clamav:clamav /run/clamav

RUN sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf \
    && sed -i 's/^#TCPSocket .*$/TCPSocket 3310/g' /etc/clamav/clamd.conf \
    && sed -i 's/^#Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

# Force recheck of the daily.cvd. For some reasons, not disabling the DNS would
# fail the update with 'Mirror not synchonized' error.
RUN freshclam --no-dns

COPY entrypoint.sh /usr/bin/
COPY --from=build-env /go/src/github.com/karunsiri/clamav-rest/clamav-rest /usr/bin/

EXPOSE 9000

ENTRYPOINT [ "entrypoint.sh" ]
