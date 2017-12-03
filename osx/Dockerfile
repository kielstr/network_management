FROM namic:5000/osx-alpine-base-webapp AS osx-network-management

WORKDIR webapp

CMD ["plackup", "-R lib bin", "-s", "Starman", "--workers=10", "-p", "8081", "-a", "bin/app.psgi"]
