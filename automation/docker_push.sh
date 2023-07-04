#!/bin/bash
	
##############################
## Get Environment Variables #
##############################
source ./automation/docker_getenv.sh
source ./automation/read_config.sh

#####################
## Docker get login #
#####################
docker login --username=$DOCKER_HUB_LOGIN_USR --password=$DOCKER_HUB_LOGIN_PSW

###############################################
## Pushing the image to repository on AWS ECR #
###############################################
docker push $REGISTRY/$REPOSITORY:$VERSION || exit 1
set +x	