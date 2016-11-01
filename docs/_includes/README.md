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
* Knows who has and had the ball (via `whohasball` state).
* Knows who is playing catch (via `friendslist` state).
* Can 'catch' the ball from any other kid, including himself.
* Can 'throw' the ball to any other kid, including himself.
* Has a unique ID (URI).
* Randomly picks which kid to throw the ball to.

## STATE TABLE

Each kid has the following State Table:

* `friendslist` : List of all kids playing, even himself (list of URIs)
* `whohasball` : The current and past 10 Kids who have had the ball (his URI)

## STARTING AND PLAYING THE GAME

To deploy the first kid (lets call him Steve):

```bash
docker run jeffdecola/hello-go steveURI
```

Because Steve is the first kid and all by himself, his State Table shall look like:

* `friendslist` : steveURI
* `whohasball` : steveURI

He will play catch with himself until another kid joins the game.

To deploy another kid (e.g. Larry), as explained above, he must know a friend (i.e. Steve):

```bash
docker run jeffdecola/hello-go larryURI steveURI
```

Hence, Larry's State Table shall look like.

* `friendslist` : larryURI, steveURI
* `whohasball` : unknown

Larry will immediately ask Steve that he wants to play (`caniplay`).
By doing so, Steve's State Table is updated with Larry's info.

* `friendslist` : larryURI, steveURI
* `whohasball` : steveURI

Steve will update Larry's State Table with the current states (`updatestate`).

Steve will also introduce Larry to all the other kids
via his `friendslist` if other kids are present (`updatestate`).

When a kid catches the ball (`throw`) he tells everyone in his `friendslist` 
that he has the ball (`updatestate`).  Everyone will update their `whohasball`  state.

## RETSful API using JSON

To accomplish the above logic, a RESTful API with json shall be used.

There are 4 basic commands:

* caniplay
* updatestate
* throw
* ihavetheball
* kick

### CANIPLAY - PUT /state

When a new kid (Larry) wants to play, he must ask his friend (Steve) if he can play.

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

If Larry does not get a response from Steve, then he can't play catch and will leave (i.e. exit).

If success Steve will updates his `freindslist` and tells all of the other kids about
Lary so they can update their respective `friendslist`.

If Steve does not get a response while updating the other kids, he issues a kick command.

Steve will also update Larry's State Table with his states.  Now Larry is up to date and in the game.

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

When a kid has the ball and wants to throw it, he randomwly picks someone from his `friendslist`
and throws it via:

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

If success, the thrower updates his `whohasball` state.  The catcher subsequently tells
everyone in his `friendslist` who has the ball as follow:

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

If the catcher does not get a response (fail) from a kid, he kicks that kid from the game.

### KICK FROM GAME- PUT /state

When a kid does not respond, it is assumed he left the game.  The kid who got
the non-reponse tell sall the othre kids who it is so they can purge him from their state.

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

If a kid left and came back, and does not receive any info, he assumes he's been
kicked and starts to go through his friends list to ask if he can join the game as a new kid.



