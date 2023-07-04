#!/bin/bash
# get variables form gitlab-ci or locals
source ./automation/read_config.sh
source ./automation/docker_getenv.sh

ec2 () {
    echo "Patching docker-compose.yml"
    echo "===================================================================="
    if [ -f docker-compose.yml ] ; then 
        sed -i -- "s/REGISTRY/$REGISTRY/g" docker-compose.yml
        sed -i -- "s/REPOSITORY/$REPOSITORY/g" docker-compose.yml
        sed -i -- "s/NAME/$NAME/g" docker-compose.yml
        sed -i -- "s/VERSION/$VERSION/g" docker-compose.yml
    else 
        echo "No se encontró el docker-compose.yml" 
        exit 1 
    fi
    echo "DEPLOY TO EC2 BRANCH: $BRANCH_NAME"
    echo "======================================================================="
    scp -o StrictHostKeyChecking=no docker-compose.yml ${EC2INSTANCE}:/home/ec2-user 
    ssh ${EC2INSTANCE} docker-compose up -d

    echo "REVIEW EC2 BRANCH: $BRANCH_NAME"
    echo "========================================================================="
    ssh ${EC2INSTANCE} docker ps |grep $REGISTRY/$REPOSITORY
}

case "$1" in

  'ec2')
    ec2 ;;

    *)
      echo "error: unknown option $1"
      exit 1
      ;;
  esac