#!/usr/bin/env bash

##########################
# Kenzan LLC -> Create Spinnaker
#
## Can your GCP Service Account do this?
## Did you create Jenkins in GKE first?
#
# nparks@kenzan.com
##########################
###
source $PWD/env.sh

PROJECT_NAME=$1
CLUSTER_NAME=$2
CLUSTER_ZONE=$3

HALYARD_K8_ACCOUNT_NAME="$CLUSTER_NAME-gkegcr"

####

echo "******************************************"
echo "=========================================="
echo " - Let's Get this Halyard Thing Together -"
echo "=========================================="

PROJECT_NAME=$(gcloud info --format='value(config.project)')
gcloud config set compute/zone $CLUSTER_ZONE

echo "==== -> Let's Get a service account created"

gcloud iam service-accounts create  $SERVICE_ACCOUNT_NAME --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:$SERVICE_ACCOUNT_NAME" --format='value(email)')

gcloud projects add-iam-policy-binding $PROJECT_NAME --role roles/storage.admin --member serviceAccount:$SA_EMAIL


mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)


gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST --iam-account $SA_EMAIL


USERNAME=_json_key
PASSWORD_FILE=$SERVICE_ACCOUNT_DEST


echo "==== -> Let's Get Halyard Configuration Going"


hal config version edit --version $SPINNAKER_VERSION

hal config storage gcs edit --project $PROJECT_NAME --bucket-location $BUCKET_LOCATION --json-path $SERVICE_ACCOUNT_DEST

hal config storage edit --type gcs

hal config features edit --pipeline-templates true


echo "==== -> Let's Get a Docker Registry using gcr.io added"

### BS to make HAL not puke over empty GCR resistry https://github.com/spinnaker/halyard/issues/608
sudo docker pull nginx
sudo docker tag nginx:latest $ADDRESS/$PROJECT_NAME/nginx
sudo gcloud docker -- push $ADDRESS/$PROJECT_NAME/nginx
#### end BS

hal config provider docker-registry account add $REGISTRY_NAME  --address $ADDRESS --username $USERNAME --password-file $PASSWORD_FILE --no-validate
hal config provider docker-registry account add $DOCKER_HUB_NAME  --address $DOCKER_ADDR --repositories $DOCKER_REPO
hal config provider docker-registry enable

#echo "==== -> NoneSense Kubectl fix"

CONTEXT_prefix="gke_"
CONTEXT=$CONTEXT_prefix$PROJECT_NAME\_$CLUSTER_ZONE\_$CLUSTER_NAME

echo "==== -> Let's get K8 on GKE associated using gcr.io added"

IMAGE_REPOS="$REGISTRY_NAME,$DOCKER_HUB_NAME"

hal config provider kubernetes account add $HALYARD_K8_ACCOUNT_NAME  --context $CONTEXT --docker-registries $IMAGE_REPOS --omit-namespaces $OMIT_NAMESPACES

hal config deploy edit --type distributed --account-name $HALYARD_K8_ACCOUNT_NAME

hal config provider kubernetes enable


echo "==== -> Let's Get that Oauth and SSL stuff set-up"

#hal config security authn oauth2 edit --client-id $OAUTH2_CLIENT_ID --client-secret $OAUTH2_CLIENT_SECRET --provider google  --user-info-requirements hd=kenzan.com

#hal config security authn oauth2 enable

##### if we are TLS terminating at load balancer
#hal config security api ssl disable
#hal config security ui ssl disable

#### we also need to update the base urls

echo "==== -> Remember Jenkins"

JENKINS_PW=`printf $(kubectl get secret --namespace $JENKINS_NAMESPACE $JENKINS_HELM_RELEASENAME-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo`
JENKINS_IP="http://$JENKINS_HELM_RELEASENAME-jenkins.$JENKINS_NAMESPACE:$JENKINS_PORT"

H_CMD="hal config ci jenkins master add jnks --address $JENKINS_IP --username $JENKINS_ADMIN_USER --password"
echo $JENKINS_PW | $H_CMD

hal config ci jenkins enable

echo "==== -> Let's Diff our Deployment real quick"

hal deploy diff


echo "======= Time to be Gangsta, this will take a while  ========"
hal deploy apply


echo "=========================================="
echo " - Hopefully there is a Spinnaker -"
echo " - Tunnel to halyard-tunnel and"
echo " - then run hal deploy connect"
echo "=========================================="
echo "******************************************"
