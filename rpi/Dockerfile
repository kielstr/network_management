FROM namic:5000/rpi-alpine-base-webapp AS rpi-network-management

RUN cpanm --no-wget -i -n Minion

WORKDIR code

CMD ["plackup", "-R lib bin", "-s", "Starman", "--workers=10", "-p", "8081", "-a", "bin/app.psgi"]
