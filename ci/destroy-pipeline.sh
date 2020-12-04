#!/bin/bash
# hello-go-deploy-marathon destroy-pipeline.sh

fly -t ci destroy-pipeline --pipeline hello-go-deploy-marathon
