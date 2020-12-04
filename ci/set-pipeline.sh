#!/bin/bash
# hello-go-deploy-marathon set-pipeline.sh

fly -t ci set-pipeline -p hello-go-deploy-marathon -c pipeline.yml --load-vars-from ../../../../../.credentials.yml
