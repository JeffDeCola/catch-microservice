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
Kids can come and go as they please.

If there is one kid left, he will toss the ball to himeslf until
another joins.

Any kid that joins the game, must be introduced to the group via
a friend.

If a kid leaves who has the ball, the last kid who threw the ball
will pick it up and conmtinur the game.

## DOCKERHUB IMAGE

Each "kid" is an instance of the `catch-microservie` DockerHub Image.

Each instance (i.e. kid) has the following properties:

* Lightweight.
* Knows who has the ball (via state).
* Can 'catch' the ball from any other kid, including himself.
* Can 'throw' the ball to any other kid, including himself.
* Has a unique ID (URI).
* Randomly picks which kid to throw the ball to.

## STATE TABLE

Each kid shall have the following State Table:

* `friendslist` : List of all kids playing catch, even himself (list of URIs)
* `whohasball` : Kid who has ball (his URI)

## DEPLOYING DOCKER IMAGE

To deploy the first kid (lets call him Steve):

```bash
docker run jeffdecola/hello-go steveURI
```

Because Steve is the first kid and all by himself, his State Table shall look like:

* `friendslist` : steveURI
* `whohasball` : steveURI

To deploy another kid (e.g. Larry), as explained above, he must know Steve:

```bash
docker run jeffdecola/hello-go larryURI steveURI
```

Hence, Larry's State Table shall look like.

* `friendslist` : larryURI, steveURI
* `whohasball` : unknown

Larry will immediately tell Steve he wants to play.
By doing so, Steve's State Table is updated with Larry's info.

* `friendslist` : larryURI, steveURI
* `whohasball` : steveURI

If their are other kids, Steve will introduce Larry to all the other kids via his `friendslist`.

## RETSful API using JSON

To accomplish the above logic, a RESTful API with json shall be used.

### NEW KID - PUT /state

When a new kid (Larry) wants to play, he must tell his friend (Steve) who is already playing.

PUT uri/state

```json
{
    "cmd": "newkid",
    "uri": "larryURI",
}
```

Reponse

```json
{
  reponse: "success",
}
```

If Larry does not get a response rom Steve, then he can't play catch and will leave (i.e. exit).

Steve will updates his State Table and tells all of theother kids about
Lary using the same PUT command.

If Steve does not get a response while updating the other kids, he ignores it.

### THROW BALL - PUT /state

When a kid has the ball and wants to throw it:

PUT uri/state

```json
{
    "cmd": "catch",
}
```

```json
{
  reponse: "success",
}
```

If the thrower does not get a reposnse, he throws it to another kid.

If success, the catcher tells everyone he has the ball by going threw his
`friendslist`.

PUT uri/state

```json
{
    "cmd": "ihaveball",
}
```

```json
{
  reponse: "success",
}
```

If teh catcher does not get a response while updating the other kids,
he ignores it.
