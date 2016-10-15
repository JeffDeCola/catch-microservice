# catch-microservice

[![Code Climate](https://codeclimate.com/github/JeffDeCola/catch-microservice/badges/gpa.svg)](https://codeclimate.com/github/JeffDeCola/catch-microservice)
[![Issue Count](https://codeclimate.com/github/JeffDeCola/catch-microservice/badges/issue_count.svg)](https://codeclimate.com/github/JeffDeCola/catch-microservice/issues)
[![Go Report Card](https://goreportcard.com/badge/jeffdecola/catch-microservice)](https://goreportcard.com/report/jeffdecola/catch-microservice)
[![GoDoc](https://godoc.org/github.com/JeffDeCola/catch-microservice?status.svg)](https://godoc.org/github.com/JeffDeCola/catch-microservice)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://jeffdecola.mit-license.org)

`catch-microservice` _is a cluster of lightweight DockerHub Images playing catch with a virtual ball._

[GitHub Webpage](https://jeffdecola.github.io/catch-microservice/),
[Docker Image](https://hub.docker.com/r/jeffdecola/catch-microservice)

## CONCEPT

Think of a group of kids on a playground playing catch.
Each kid can see the other kids as they toss the ball around.
Sometimes a kid will leave or a new kid will enter the group.

If there is one kid left, he will toss the ball to himeslf until
another kid wants to play catch.

If a kid leaves who has the ball, the last kid who threw the ball will pick it up.

## DOCKERHUB IMAGE

Each kid is an instance of the `catch-microservie` DockerHub Image.

Each instance (i.e. kid):

* is lightweight.
* knows which kid has the ball (via state).
* can 'catch' a virtual ball from any othre kid, including himself.
* can 'throw' a virtual ball to any other kid, including himself.
* has a unique ID (URI).
* shall randomly pick which kid to throw the ball to.

## STATE

* `listofkids` : List of all kids playing catch, even himself (list of URIs)
* `whohasball` : URI of kid who hs ball

## DEPLOYING DOCKER IMAGE

To deploy the first kid to play catch run.  Lets call this kid steve:

```bash
docker run jeffdecola/hello-go steveURI
```

Becaseu steve is the first kid and all by himself, the satte shall look like

* `listofkids` : steveURI
* `whohasball` : steveURI

To deploy another kid, he must know someone who is playing.

```bash
docker run jeffdecola/hello-go larryURI steveURI
```

This will place the uri of the first kid in both the kiss list and whohasball state.

* `listofkids` : larryURI, steveURI
* `whohasball` : unknown

## RETSful API using JSON

### NEW KID - PUT /state

When a new kid wants to play, he tells his friend.  His friend then updates
the rest of the kids using the same PUT command.

PUT _friendsuri_/state

{
    "uri": "_kidsuri_",
    "cmd": "newkid",
}

If there is a no-reponse, then the new kid can't play catch and will leave (i.e. exit).

### THROW PUT /state

{
    "cmd": "catchball",
}

The Catchnig then has to update everyone he knows that he has the ball.

{
    "uri": "_catchesuri_",
    "cmd": "ihaveball",
}
