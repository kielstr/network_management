FROM namic:5000/osx-alpine-base-minion as osx-minion_worker

RUN apk add perl-dbd-mysql

WORKDIR data

ADD ./data data

CMD ./db_ready.pl ./worker.pl