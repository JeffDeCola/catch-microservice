# catch-microservice Dockerfile used to build docker image on concourse ci

FROM alpine

MAINTAINER Jeff DeCola (https://github.com/JeffDeCola/catch-microservice)

# Put the binary into the container
COPY catch-microservice /

# Add the ailibty to /bin/bash
RUN apk add --update bash && rm -rf /var/cache/apk/*

# Runs the binary when someone uses it.
CMD /catch-microservice