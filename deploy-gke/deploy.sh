#!/usr/bin/env bash

GCP_info="deploy-gke/GCP.info"
APP_YAML="deploy-gke/app.yaml"
GKE=`grep GKE ${GCP_info} | cut -f2 -d:`
REGION=`grep REGION ${GCP_info} | cut -f2 -d:`
PROJECT=`grep PROJECT ${GCP_info} | cut -f2 -d:`

VERSION=$1

sed -i "s/APP/${IMAGE_NAME}/g; s/VERSION/${VERSION}/g" ${APP_YAML}

gcloud auth activate-service-account --key-file=${GOOGLE_CRED}
gcloud container clusters get-credentials ${GKE} --region ${REGION} --project ${PROJECT}

kubectl apply -f ${APP_YAML}
