# build stage
FROM golang:alpine AS build-env
ADD . /go/src/github.com/karunsiri/clamav-rest/
RUN cd /go/src/github.com/karunsiri/clamav-rest && go build -v

# dockerize stage
FROM alpine
MAINTAINER Karun Siritheerathamrong <karoon.siri@gmail.com>

RUN apk --no-cache add clamav clamav-libunrar bash bind-tools rsync \
    && mkdir /run/clamav \
    && chown clamav:clamav /run/clamav

RUN mkdir -p /usr/local/sbin/ \
    && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/clamav-unofficial-sigs.sh -O /usr/local/sbin/clamav-unofficial-sigs.sh \
    && chmod 755 /usr/local/sbin/clamav-unofficial-sigs.sh \
    && mkdir -p /etc/clamav-unofficial-sigs/ \
    && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/master.conf -O /etc/clamav-unofficial-sigs/master.conf \
    && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/user.conf -O /etc/clamav-unofficial-sigs/user.conf \
    && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/os/os.alpine.conf -O /etc/clamav-unofficial-sigs/os.conf

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
