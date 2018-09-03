[Docker Image](https://hub.docker.com/r/jeffdecola/catch-microservice)

# CONCEPT

Think of a group of people on a playground playing
the game catch.

There is one ball being thrown around randomly from person to person.

People can come and go as they please.

If there is one person left, s/he will toss the ball to himeslf until
another person joins the game.

Any person that joins must be introduced to the entire group via a friend.

If a person has the ball and leave the game, another person will
pick it up and continue playing catch.

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
* Randomly picks which preson to throw the ball to.

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
docker run jeffdecola/hello-go larryID steveID
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

### UPDTAESTATE - PUT /state

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
The kid who got the non-reponse tell sall the othre kids who it is so
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



