#!/bin/bash
# catch-microservice update_concourse.sh

fly -t ci set-pipeline -p catch-microservice -c ci/pipeline.yml --load-vars-from ../.credentials.yml
