# CONCOURSE CONTINUOUS INTEGRATION

I use concourse ci to,

* Copy and edit `README.md` to `/docs/_includes/README.md` for
  [GitHub Webpage](https://jeffdecola.github.io/catch-microservice/)
* TEST code
* BUILD docker image
* PUSH to dockerhub
* DEPLOY to marathon
* Alert me of the progress via repo status and slack

## PIPELINE

The concourse
[pipeline.yml](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/pipeline.yml)
shows the entire ci flow. Visually, it looks like,

![IMAGE - catch-microservice concourse ci pipeline - IMAGE](docs/pics/catch-microservice-pipeline.jpg)

## JOBS, TASKS AND RESOURCE TYPES

The concourse `jobs` and `tasks` are,

* `job-readme-github-pages` runs task
  [task-readme-github-pages.yml](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/tasks/task-readme-github-pages.yml)
  that kicks off shell script
  [readme-github-pages.sh](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/scripts/readme-github-pages.sh)
* `job-unit-tests` runs task
  [task-unit-tests.yml](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/tasks/task-unit-tests.yml)
  that kicks off shell script
  [unit-tests.sh](https://github.com/JeffDeCola/catch-microservice/tree/master/ci/scripts/unit-tests.sh)
* `job-build-push` runs task
  [task-build-push.yml](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/tasks/task-build-push.yml)
  that kicks off shell script
  [build-push.sh](https://github.com/JeffDeCola/catch-microservice/tree/master/ci/scripts/build-push.sh)
* `job-deploy` runs task
  [task-deploy.yml](https://github.com/JeffDeCola/catch-microservice/blob/master/ci/tasks/task-deploy.yml)
  that kicks off shell script
  [deploy.sh](https://github.com/JeffDeCola/catch-microservice/tree/master/ci/scripts/deploy.sh)

The concourse `resources types` are,

* `catch-microservice` uses a resource type
  [docker-image](https://hub.docker.com/r/concourse/git-resource/)
  to PULL a repo from github
* `resource-dump-to-dockerhub` uses a resource type
  [docker-image](https://hub.docker.com/r/concourse/docker-image-resource/)
  to PUSH a docker image to dockerhub.
* `resource-marathon` users a resource type
  [docker-image](https://hub.docker.com/r/ckaznocha/marathon-resource)
  to DEPLOY the newly created docker image to marathon.
* `resource-slack-alert` uses a resource type
  [docker image](https://hub.docker.com/r/cfcommunity/slack-notification-resource)
  that will notify slack on your progress
* `resource-repo-status` uses a resource type
  [docker image](https://hub.docker.com/r/dpb587/github-status-resource)
  that will update your git status for that particular commit

For more information on using concourse for continuous integration,
refer to my
[concourse-cheat-sheet](https://github.com/JeffDeCola/my-cheat-sheets/tree/master/software/operations-tools/continuous-integration-continuous-deployment/concourse-cheat-sheet).
