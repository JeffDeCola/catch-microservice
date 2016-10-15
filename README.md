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
another joins.

If a kid leaves who has the ball, the last kid who threw the ball
last will pick it up.

## DOCKERHUB IMAGE

Each kid is an instance of the `catch-microservie` DockerHub Image.

Each instance (i.e. kid):

* is lightweight.
* knows who has the ball (via state).
* can 'catch' the ball from any other kid, including himself.
* can 'throw' the ball to any other kid, including himself.
* has a unique ID (URI).
*when he has the ball shall randomly pick which kid to throw the ball to.

## STATE TABLE

Each kid shall have the following state:

* `listofkids` : List of all kids playing catch, even himself (list of URIs)
* `whohasball` : URI of kid who has ball

## DEPLOYING DOCKER IMAGE

To deploy the first kid (lets call him Steve) to play catch:

```bash
docker run jeffdecola/hello-go steveURI
```

Becaseu Steve is the first kid and all by himself, his state table shall look like

* `listofkids` : steveURI
* `whohasball` : steveURI

To deploy another kid (e.g. Larry), he must know Steve:

```bash
docker run jeffdecola/hello-go larryURI steveURI
```

Hence, Larry's state talbe shall look like.

* `listofkids` : larryURI, steveURI
* `whohasball` : unknown

Larry will immediately tell Steve he want to play catch.  By doing so, Steve's state table is updated.

* `listofkids` : larryURI, steveURI
* `whohasball` : steveURI

If their where more kids, Steve will then update everyone that is listed in `listofkids` as to who the new kid is.

## RETSful API using JSON

To accomplish the above logic, a RESTful API with json shall be used.

### NEW KID - PUT /state

When a new kid (Larry) wants to play, he must tell his friend (Steve) who is already playing.

PUT uri/state

```json
{
    "uri": "larryURI",
    "cmd": "newkid",
}
```

His friend Steve then updates the rest of the kids using the same PUT command.

If there is a no-reponse, then Larry can't play catch and will leave (i.e. exit).

### THROW BALL - PUT /state

When a kid has the ball and wants to throw it:

PUT uri/state

```json
{
    "cmd": "catchball",
}
```

The catcher then has to update everyone he knows that he has the ball by going threw his
`listofkids`.

PUT uri/state

```json
{
    "uri": "kidsURI",
    "cmd": "ihaveball",
}
```