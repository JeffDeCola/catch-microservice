#!/bin/sh
# catch-microservice deploy.sh

echo " "

if [ "$1" = "-debug" ]
then
    echo "deploy.sh -debug (START)"
    # set -e causes the shell to exit if any subcommand or pipeline returns a non-zero status. Needed for concourse.
    # set -x enables a mode of the shell where all executed commands are printed to the terminal.
    set -e -x
    echo " "
else
    echo "deploy.sh (START)"
    # set -e causes the shell to exit if any subcommand or pipeline returns a non-zero status.  Needed for concourse.
    set -e
    echo " "
fi

echo "GOAL ----------------------------------------------------------------------------------"
echo " "

echo "The goal is to deploy docker image to docker"
echo " "

echo "CHECK THINGS --------------------------------------------------------------------------"
echo " "

echo "At start, you should be in a /tmp/build/xxxxx directory with two folders:"
echo "   /catch-microservice"
echo " "

echo "pwd is: $PWD"
echo " "

echo "List whats in the current directory"
ls -la
echo " "

echo "DOCKER RUN ----------------------------------------------------------------------------"
echo " "

echo "DOCKER HOST INFO:"
# echo "$DOCKER_HOST_SSH_PRIVATE_KEY_FILE"
echo "$DOCKER_HOST_PORT"
echo "$DOCKER_HOST_USER"
echo "$DOCKER_HOST_IP"
echo " "

echo "Put private key in temp file"
echo "$DOCKER_HOST_SSH_PRIVATE_KEY_FILE" >> private-key-file.txt
cat private-key-file.txt
chmod 600 private-key-file.txt
echo " "

echo "Stop old container if it exists - Ignore if you get an error"
echo "docker stop catch-microservice || true "
ssh -o StrictHostKeyChecking=no \
    -i private-key-file.txt -p "$DOCKER_HOST_PORT" "$DOCKER_HOST_USER"@"$DOCKER_HOST_IP" \
    'docker stop catch-microservice || true'
echo " "

echo "Remove old container if it exsits - Ignore if you get an error"
echo "docker rm catch-microservice || true"
ssh -o StrictHostKeyChecking=no \
    -i private-key-file.txt -p "$DOCKER_HOST_PORT" "$DOCKER_HOST_USER"@"$DOCKER_HOST_IP" \
    'docker rm catch-microservice || true'
echo " "

echo "docker run --name catch-microservice -dit jeffdecola/catch-microservice"
ssh -o StrictHostKeyChecking=no \
    -i private-key-file.txt -p "$DOCKER_HOST_PORT" "$DOCKER_HOST_USER"@"$DOCKER_HOST_IP" \
    'docker run --name catch-microservice -dit jeffdecola/catch-microservice'
echo " "

echo "rm private-key-file.txt"
rm private-key-file.txt
echo " "

echo "You can now run docker commands such as:"
echo "docker run --name catch-microservice -dit jeffdecola/catch-microservice"
echo "docker exec -i -t catch-microservice /bin/bash"
echo "docker logs catch-microservice"
echo "docker rm -f catch-microservice"
echo " "

echo "deploy.sh (END)"
echo " "
