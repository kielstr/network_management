#FROM namic:5000/osx-webapp-base AS network-management
FROM namic:5000/rpi-webapp-base AS network-management

WORKDIR webapp

CMD ["plackup", "-R lib bin", "-s", "Starman", "--workers=10", "-p", "8081", "-a", "bin/app.psgi"]
