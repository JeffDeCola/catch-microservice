#!/bin/sh
# catch-microservice build-push.sh

echo " "

if [ "$1" = "-debug" ]
then
    echo "build-push.sh -debug (START)"
    echo " "
    # set -x enables a mode of the shell where all executed commands are printed to the terminal.
    set -x
    echo " "
else
    echo " "
    echo "build-push.sh.sh (START)"
    echo " "
fi

echo "cd up to /catch-microservice"
cd ..
echo " "

echo "Create a binary catch in /bin"
go build -o bin/catch main.go
echo ""

echo "Copy the binary to /build-push because docker needs it with Dockerfile"
cp bin/catch /build-push/.
echo " "

echo "cd build-push"
cd build-push
echo " "

echo "Build your docker image from binary /bin/catch using /build-push/Dockerfile"
docker build -t jeffdecola/catch-microservice .
echo " "

echo "Assuming you are logged in, lets push your built docker image to DockerHub"
docker push jeffdecola/catch-microservice
echo

echo "build-push.sh -concoure -debug (END)"
echo " "
