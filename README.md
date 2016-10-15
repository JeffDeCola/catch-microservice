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

Each instance:

* is lightweight.
* knows which instance has the ball (via internal state).
* can 'catch' a virtual ball from any instance.
* can 'throw' a virtual ball to any instance.
* can throw the ball up and down to itself.
* has a unique ID they get at creation.
* shall randomly pick who to throw the ball to.


