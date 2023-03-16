# CATCH MICROSERVICE

[![Tag Latest](https://img.shields.io/github/v/tag/jeffdecola/catch-microservice)](https://github.com/JeffDeCola/catch-microservice/tags)
[![Go Reference](https://pkg.go.dev/badge/github.com/JeffDeCola/catch-microservice.svg)](https://pkg.go.dev/github.com/JeffDeCola/catch-microservice)
[![Go Report Card](https://goreportcard.com/badge/github.com/JeffDeCola/catch-microservice)](https://goreportcard.com/report/github.com/JeffDeCola/catch-microservice)
[![codeclimate Maintainability](https://api.codeclimate.com/v1/badges/3bbad863dff19a54d032/maintainability)](https://codeclimate.com/github/JeffDeCola/catch-microservice/maintainability)
[![codeclimate Issue Count](https://codeclimate.com/github/JeffDeCola/catch-microservice/badges/issue_count.svg)](https://codeclimate.com/github/JeffDeCola/catch-microservice/issues)
[![Docker Pulls](https://badgen.net/docker/pulls/jeffdecola/catch-microservice?icon=docker&label=pulls)](https://hub.docker.com/r/jeffdecola/catch-microservice/)
[![MIT License](http://img.shields.io/:license-mit-blue.svg)](http://jeffdecola.mit-license.org)
[![jeffdecola.com](https://img.shields.io/badge/website-jeffdecola.com-blue)](https://jeffdecola.com)

```text
*** THE REPO IS UNDER CONSTRUCTION - CHECK BACK SOON ***
```

_A cluster of lightweight docker images playing catch with a virtual ball._

Table of Contents

* [OVERVIEW](https://github.com/JeffDeCola/catch-microservice#overview)
* [PREREQUISITES](https://github.com/JeffDeCola/catch-microservice#prerequisites)
* [SOFTWARE STACK](https://github.com/JeffDeCola/catch-microservice#software-stack)
* [HOW IT WORKS](https://github.com/JeffDeCola/catch-microservice#how-it-works)
  * [STARTING AND PLAYING THE GAME](https://github.com/JeffDeCola/catch-microservice#starting-and-playing-the-game)
  * [RETSful API using JSON](https://github.com/JeffDeCola/catch-microservice#retsful-api-using-json)
  * [CANIPLAY - PUT /state](https://github.com/JeffDeCola/catch-microservice#caniplay---put-state)
  * [UPDATESTATE - PUT /state](https://github.com/JeffDeCola/catch-microservice#updatestate---put-state)
  * [THROW BALL - PUT /state](https://github.com/JeffDeCola/catch-microservice#throw-ball---put-state)
  * [KICK FROM GAME- PUT /state](https://github.com/JeffDeCola/catch-microservice#kick-from-game--put-state)
  * [KID NOT RECEIVING ANY INFO - PUT /state](https://github.com/JeffDeCola/catch-microservice#kid-not-receiving-any-info---put-state)
* [CREATE THE DOCKER IMAGE](https://github.com/JeffDeCola/catch-microservice#create-the-docker-image)
  * [RUN](https://github.com/JeffDeCola/catch-microservice#run)
  * [CREATE BINARY](https://github.com/JeffDeCola/catch-microservice#create-binary)
  * [STEP 1 - TEST](https://github.com/JeffDeCola/catch-microservice#step-1---test)
  * [STEP 2 - BUILD (DOCKER IMAGE VIA DOCKERFILE)](https://github.com/JeffDeCola/catch-microservice#step-2---build-docker-image-via-dockerfile)
  * [STEP 3 - PUSH (TO DOCKERHUB)](https://github.com/JeffDeCola/catch-microservice#step-3---push-to-dockerhub)
  * [STEP 4 - DEPLOY (TO DOCKER)](https://github.com/JeffDeCola/catch-microservice#step-4---deploy-to-docker)
  * [CONTINUOUS INTEGRATION & DEPLOYMENT](https://github.com/JeffDeCola/catch-microservice#continuous-integration--deployment)

Documentation and Reference

* [Microservices cheat sheet](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/development/software-architectures/microservices/microservices-cheat-sheet)
* The
  [catch-microservice docker image](https://hub.docker.com/r/jeffdecola/catch-microservice)
  on DockerHub
* This repos
  [github webpage](https://jeffdecola.github.io/catch-microservice/)
  _built with
  [concourse](https://github.com/JeffDeCola/catch-microservice/blob/master/ci-README.md)_

## OVERVIEW

Think of a group of people on a playground playing
the game catch. There is one ball being thrown around randomly from person to person.
People can come and go as they please.
If there is one person left, they will toss the ball to themselves until
another person joins the game.

Any person that joins must be introduced to the entire group via a friend.
If a person has the ball and leave the game, another person will
pick it up and continue playing catch.

## PREREQUISITES

You will need the following go packages,

```bash
go get -u -v github.com/sirupsen/logrus
go get -u -v github.com/cweill/gotests/...
```

## SOFTWARE STACK

* DEVELOPMENT
  * [go](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/development/languages/go-cheat-sheet)
  * gotests
* OPERATIONS
  * [concourse/fly](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations/continuous-integration-continuous-deployment/concourse-cheat-sheet)
    (optional)
  * [docker](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations/orchestration/builds-deployment-containers/docker-cheat-sheet)
* SERVICES
  * [dockerhub](https://hub.docker.com/)
  * [github](https://github.com/)

Where,

* **GUI**
  _golang net/http package and ReactJS_
* **Routing & REST API framework**
  _golang gorilla/mux package_
* **Backend**
  _golang_
* **Database**
  _N/A_

## HOW IT WORKS

Each "person" is an instance of the
[catch-microservice](https://hub.docker.com/r/jeffdecola/catch-microservice)
DockerHub image.

Each instance (i.e. people) has the following features:

* Lightweight.
* Knows who has and had the ball (via `whohasball` state).
* Knows who is playing catch (via `friendslist` state).
* Can 'catch' the ball from any other person, including himself.
* Can 'throw' the ball to any other person, including himself.
* Has a unique ID (URI).
* Randomly picks which person to throw the ball to.

Each person has the following State Table:

* `friendslist` : List of all people playing, even himself (list of URIs)
* `whohasball` : ???????? (his URI)

### STARTING AND PLAYING THE GAME

To deploy the first person (lets call him Steve):

```bash
docker run jeffdecola/catch-microservice StevesID
```

Because Steve is the first kid and all by himself, his State Table shall look like:

* `friendslist` : StevesID
* `whohasball` : StevesID

Steve will play catch with himself until another person joins the game.

To deploy another person (e.g. Julie), she must know another person
(e.g. Steve):

```bash
docker run jeffdecola/catch-microservice larryID steveID
```

Hence, Julies's State Table shall look like.

* `friendslist` : larryID, steveID
* `whohasball` : unknown

Steve will immediately throw the ball to julie.

Steve will update Larry's State Table with the current states (`updatestate`).

Steve will also introduce Larry to all the other kids
via his `friendslist` if other kids are present (`updatestate`).

When a kid catches the ball (`throw`) he tells everyone in his `friendslist`
that he has the ball (`updatestate`).  Everyone will update their `whohasball`  state.

### RETSful API using JSON

To accomplish the above logic, a RESTful API with json shall be used.

In gom, the http package lets us map request paths to functions.

There are 4 basic commands:

* caniplay
* updatestate
* throw
* ihavetheball
* kick

### CANIPLAY - PUT /state

When a new kid (Larry) wants to play, he must ask his friend (Steve)
if he can play.

PUT uri/state

```json
{
    "cmd": "caniplay",
    "uri": "larryURI"
}
```

Reponse:

```json
{
  "response": "success"
}
```

If Larry does not get a response from Steve, then he can't play catch
and will leave (i.e. exit).

If success Steve will updates his `freindslist` and tells all of
the other kids about Larry so they can update their respective `friendslist`.

If Steve does not get a response while updating the other kids,
he issues a kick command.

Steve will also update Larry's State Table with his states.
Now Larry is up to date and in the game.

### UPDATESTATE - PUT /state

When a kids wants ot update a friends state.

PUT uri/state

```json
{
    "cmd": "updatestate",
    "friendslist": "URI",
    "addtofriendslist": "URI",
    "whohasball" : {"URI", "URI"}
}
```

Reponse:

```json
{
  "response": "success"
}
```

### THROW BALL - PUT /state

When a kid has the ball and wants to throw it, he randomwly picks someone from
his `friendslist` and throws it via:

PUT uri/state

```json
{
    "cmd": "throw"
}
```

Response:

```json
{
  "response": "success"
}
```

If he does not get a reposnse (fail), he first kicks the kid frmo the game and then
throws the ball to another kid.

If success, the thrower updates his `whohasball` state.  The catcher
subsequently tells everyone in his `friendslist` who has the ball as follow:

PUT uri/state

```json
{
    "cmd": "ihaveball",
    "uri": "catcherURI"
}
```

Response:

```json
{
  "response": "success"
}
```

On success of updating all kids, the catchre is ready to throw the ball.

If the catcher does not get a response (fail) from a kid, he kicks
that kid from the game.

### KICK FROM GAME- PUT /state

When a kid does not respond, it is assumed he left the game.
The kid who got the non-response tell all the other kids who it is so
they can purge him from their state.

PUT uri/state

```json
{
    "cmd": "kick",
    "uri": "kickURI"
}
```

Response:

```json
{
  "response": "success"
}
```

### KID NOT RECEIVING ANY INFO - PUT /state

If a kid left and came back, and does not receive any info,
he assumes he's been kicked and starts to go through his friends
list to ask if he can join the game as a new kid.

## CREATE THE DOCKER IMAGE

How I created, tested, and deployed the docker image.

### RUN

To
[run.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/run.sh),

```bash
cd catch-microservice-code
go run main.go
```

As a placeholder, every 2 seconds it will print,

```txt
    INFO[0000] Let's Start this!
    Hello everyone, count is: 1
    Hello everyone, count is: 2
    Hello everyone, count is: 3
    etc...
```

### CREATE BINARY

To
[create-binary.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/bin/create-binary.sh),

```bash
cd catch-microservice-code/bin
go build -o catch-microservice ../main.go
./catch-microservice
```

This binary will not be used during a docker build
since it creates it's own.

### STEP 1 - TEST

To create unit `_test` files,

```bash
cd catch-microservice-code
gotests -w -all main.go
```

To run
[unit-tests.sh](https://github.com/JeffDeCola/catch-microservice/tree/master/catch-microservice-code/test/unit-tests.sh),

```bash
go test -cover ./... | tee test/test_coverage.txt
cat test/test_coverage.txt
```

### STEP 2 - BUILD (DOCKER IMAGE VIA DOCKERFILE)

To
[build.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/build/build.sh)
with a
[Dockerfile](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/build/Dockerfile),

```bash
cd catch-microservice-code
docker build -f build/Dockerfile -t jeffdecola/catch-microservice .
```

You can check and test this docker image,

```bash
docker images jeffdecola/catch-microservice:latest
docker run --name catch-microservice -dit jeffdecola/catch-microservice
docker exec -i -t catch-microservice /bin/bash
docker logs catch-microservice
docker rm -f catch-microservice
```

In **stage 1**, rather than copy a binary into a docker image (because
that can cause issues), the Dockerfile will build the binary in the
docker image,

```bash
FROM golang:alpine AS builder
RUN go get -d -v
RUN go build -o /go/bin/catch-microservice main.go
```

In **stage 2**, the Dockerfile will copy the binary created in
stage 1 and place into a smaller docker base image based
on `alpine`, which is around 13MB.

### STEP 3 - PUSH (TO DOCKERHUB)

You must be logged in to DockerHub,

```bash
docker login
```

To
[push.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/push/push.sh),

```bash
docker push jeffdecola/catch-microservice
```

Check the
[catch-microservice docker image](https://hub.docker.com/r/jeffdecola/catch-microservice)
at DockerHub.

### STEP 4 - DEPLOY (TO DOCKER)

To
[deploy.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/catch-microservice-code/deploy/deploy.sh),

```bash
cd catch-microservice-code
docker run --name catch-microservice -dit jeffdecola/catch-microservice
docker exec -i -t catch-microservice /bin/bash
docker logs catch-microservice
docker rm -f catch-microservice
```

### CONTINUOUS INTEGRATION & DEPLOYMENT

Refer to
[ci-README.md](https://github.com/JeffDeCola/catch-microservice/blob/master/ci-README.md)
on how I automated the above steps.
