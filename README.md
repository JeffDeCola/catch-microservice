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
another joins the game.

Any kid that joins must be introduced to the entire group via a friend.

If a kid leaves who has the ball, the last kid who threw the ball
will pick it up and continue the game.

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
* `whohasball` : The current and past 10 Kids who has ball (his URI)

## STARTING AND PLAYING THE GAME

To deploy the first kid (lets call him Steve):

```bash
docker run jeffdecola/hello-go steveURI
```

Because Steve is the first kid and all by himself, his State Table shall look like:

* `friendslist` : steveURI
* `whohasball` : steveURI

He will play catch with himself until another kid joins.

To deploy another kid (e.g. Larry), as explained above, he must know a friend (i.e. Steve):

```bash
docker run jeffdecola/hello-go larryURI steveURI
```

Hence, Larry's State Table shall look like.

* `friendslist` : larryURI, steveURI
* `whohasball` : unknown

Larry does not know who has the ball.  He will be updated when he catches for the first time.

Larry will immediately tell Steve he wants to play.
By doing so, Steve's State Table is updated with Larry's info.

* `friendslist` : larryURI, steveURI
* `whohasball` : steveURI

When there are other kids, Steve will introduce Larry to all the other kids
via his `friendslist`.

When a kid catches the ball he tells everyone in his `friendslist` who has had the
ball.  Everyone will update their `whohasball`  state.

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

Reponse:

```json
{
  response: "success"
}
```

If Larry does not get a response rom Steve, then he can't play catch and will leave (i.e. exit).

If success Steve will updates his `freindslist` and tells all of the other kids about
Lary using the same PUT command so they can update their respective `friendslist`.

If Steve does not get a response while updating the other kids, he ignores it.

### THROW BALL - PUT /state

When a kid has the ball and wants to throw it, he randomwly picks someone from his friends
list and throws it:

PUT uri/state

```json
{
    "cmd": "catch",
}
```

Response:

```json
{
  response: "success"
}
```

If he does not get a reposnse, he throws it to another kid.

If success, the catcher tells everyone in his `friendslist` who has the ball.

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
  response: "success"
}
```

If the catcher does not get a response while updating the other kids,
he ignores it.

