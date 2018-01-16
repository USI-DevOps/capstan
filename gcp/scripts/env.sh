
############################################# Tools instance

TOOLS_SERVICE_ACCOUNT_NAME=halyard-tunnel-tools

############################################# GCP / GKE

#ZONE=us-central1-f
#FIXME do not use other zones yet
#OTHER_ZONES=""
#OTHER_ZONES="--additional-zones us-central1-b,us-central1-c,us-central1-a"
#### Expected JenkinsSpinnakerClusterName Cluster Name
#CLUSTER_NAME=cdci-runtime
#HALYARD_K8_ACCOUNT_NAME="$CLUSTER_NAME-gkegcr"
#There will be a N nodes per zone, if in 4 zones this will result in 4 nodes
#NODE_PER_ZONE=3
#cloud storage location
BUCKET_LOCATION=us

############################################### Jenkins

##### TLS Paths if you have them enter them here and comment out line in create_jenkins.sh otherwise the files will be created at this locations
TLS_CERT="certificate.crt"
TLS_KEY="privatekey.key"
JENKINSNS="jenkins"
#only used for spinnaker configuration
JENKINS_ADMIN_USER="admin"
JENKINS_SAVED_PW=JenkinsPassword.txt
JENKINS_SAVED_IP=JenkinsIP.txt

JENKINS_PORT="8080"
JENKINS_NAMESPACE=$JENKINSNS
JENKINS_HELM_RELEASENAME="ci"

############################################ Halyard Spinnaker
ADDRESS=gcr.io
SERVICE_ACCOUNT_NAME=gcr-spinnaker
SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json
REGISTRY_NAME=imagerepository
SPINNAKER_VERSION="1.5.4"

DOCKER_HUB_NAME="dockerhubimagerepository"
DOCKER_REPO="netflixoss/eureka netflixoss/zuul owasp/zap2docker-stable"
DOCKER_ADDR="index.docker.io"

OMIT_NAMESPACES=$JENKINSNS
# we are assuming that glcoud credentials where added properly
KUBECONFIG=".kube/config"
