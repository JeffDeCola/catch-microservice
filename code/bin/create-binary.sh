#!/bin/sh -e
# catch-microservice code create-binary.sh

echo " "

if [ "$1" = "-debug" ]
then
    echo "************************************************************************"
    echo "* create-binary.sh -debug (START) **************************************"
    echo "************************************************************************"
    # set -x enables a mode of the shell where all executed commands are printed to the terminal.
    set -x
    echo " "
else
    echo "************************************************************************"
    echo "* create-binary.sh (START) *********************************************"
    echo "************************************************************************"
    echo " "
fi

echo "Create a binary catch in /bin"
echo "    Kick off executable with ./catch"
go build -o catch ../main.go
echo " "

echo "************************************************************************"
echo "* create-binary.sh (END) ***********************************************"
echo "************************************************************************"
echo " "
