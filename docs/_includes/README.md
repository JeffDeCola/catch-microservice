_built with
[concourse ci](https://github.com/JeffDeCola/catch-microservice/blob/master/ci-README.md)_

# OVERVIEW

Think of a group of people on a playground playing
the game catch.

There is one ball being thrown around randomly from person to person.

People can come and go as they please.

If there is one person left, s/he will toss the ball to himself until
another person joins the game.

Any person that joins must be introduced to the entire group via a friend.

If a person has the ball and leave the game, another person will
pick it up and continue playing catch.

## PREREQUISITES

I used the following language,

* [go](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/development/languages/go-cheat-sheet)

You will need the following go packages,

```bash
go get -u -v github.com/sirupsen/logrus
```

To build a docker image you will need docker on your machine,

* [docker](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations-tools/orchestration/builds-deployment-containers/docker-cheat-sheet)

To push a docker image you will need,

* [DockerHub account](https://hub.docker.com/)

To deploy to `mesos/marathon` you will need,

* [marathon](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations-tools/orchestration/cluster-managers-resource-management-scheduling/marathon-cheat-sheet)
* [mesos](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations-tools/orchestration/cluster-managers-resource-management-scheduling/mesos-cheat-sheet)

As a bonus, you can use Concourse CI,

* [concourse](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations-tools/continuous-integration-continuous-deployment/concourse-cheat-sheet)

## RUN

The following steps are located in
[run.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/code/run.sh).

To run
[main.go](https://github.com/JeffDeCola/catch-microservice/blob/master/code/main.go)
from the command line,

```bash
cd code
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

## CREATE BINARY

The following steps are located in
[create-binary.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/code/bin/create-binary.sh).

```bash
cd code
go build -o bin/catch main.go
cd bin
./catch
```

This binary will not be used during a docker build
since it creates it's own.

## DOCKERHUB IMAGE

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

## STATE TABLE

Each person has the following State Table:

* `friendslist` : List of all people playing, even himself (list of URIs)
* `whohasball` : ???????? (his URI)

## STARTING AND PLAYING THE GAME

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

## RETSful API using JSON

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

## STEP 1 - TEST

The following steps are located in
[unit-tests.sh](https://github.com/JeffDeCola/catch-microservice/tree/master/code/test/unit-tests.sh).

To unit test the code,

```bash
cd code
go test -cover ./... | tee test/test_coverage.txt
cat test/test_coverage.txt
```

To create `_test` files,

```bash
gotests -w -all main.go
```

## STEP 2 - BUILD (DOCKER IMAGE VIA DOCKERFILE)

The following steps are located in
[build.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/code/build-push/build.sh).

We will be using a multi-stage build using a
[Dockerfile](https://github.com/JeffDeCola/catch-microservice/blob/master/code/build-push/Dockerfile).
The end result will be a very small docker image around 13MB.

```bash
cd code
docker build -f build-push/Dockerfile -t jeffdecola/catch-microservice .
```

You can check and test this docker image,

```bash
docker images jeffdecola/catch-microservice:latest
docker run --name catch-microservice -dit jeffdecola/catch-microservice
docker exec -i -t catch-microservice /bin/bash
docker logs catch-microservice
```

In **stage 1**, rather than copy a binary into a docker image (because
that can cause issues), **the Dockerfile will build the binary in the
docker image.**

If you open the DockerFile you can see it will get the dependencies and
build the binary in go,

```bash
FROM golang:alpine AS builder
RUN go get -d -v
RUN go build -o /go/bin/catch-microservice main.go
```

In **stage 2**, the Dockerfile will copy the binary created in
stage 1 and place into a smaller docker base image based
on `alpine`, which is around 13MB.

## STEP 3 - PUSH (TO DOCKERHUB)

The following steps are located in
[push.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/code/build-push/push.sh).

If you are not logged in, you need to login to dockerhub,

```bash
docker login
```

Once logged in you can push to DockerHub,

```bash
docker push jeffdecola/catch-microservice
```

Check the
[catch-microservice](https://hub.docker.com/r/jeffdecola/catch-microservice)
docker image at DockerHub.

## STEP 4 - DEPLOY (TO MARATHON)

The following steps are located in
[deploy.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/code/deploy-marathon/deploy.sh).

Pull the `catch-microservice` docker image
from DockerHub and deploy to mesos/marathon.

This is actually very simple, you just PUT the
[app.json](https://github.com/JeffDeCola/catch-microservice/blob/master/code/deploy-marathon/app.json)
file to mesos/marathon. This .json file tells marathon what to do.

```bash
cd deploy-marathon
curl -X PUT http://192.168.20.117:8080/v2/apps/catch-long-running \
-d @app.json \
-H "Content-type: application/json"
```

## CONTINUOUS INTEGRATION & DEPLOYMENT

Refer to
[ci-README.md](https://github.com/JeffDeCola/catch-microservice/blob/master/ci-README.md)
on how I automated the above steps.
