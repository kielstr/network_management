FROM namic:5000/osx-alpine-base-minion

RUN apk add perl-dbd-mysql

WORKDIR data

ADD ./wait-for-it.sh /data/wait-for-it.sh
ADD ./data data

CMD ./wait-for-it.sh mysql:3306 -- ./worker.pl