#!/bin/bash

NS="ws1"
CONTEXT="${2:-local}" 

if [[ -z $2 ]]; then
  printf "using default context: local, you can specify different context \n"
  printf "run ./cluster.sh [state] [context]\n\tstate = up | down\n\tcontext = azure | local\n"
fi

source "env/$CONTEXT.env"

kubectl config use-context $K8S_CONTEXT

if [[ $1 == "up" ]]; then
  kubectl create namespace $NS
  helm repo add bitnami https://charts.bitnami.com/bitnami
  # refer to: https://artifacthub.io/packages/helm/bitnami/zookeeper
  helm install zookeeper --set name=zookeeper,livenessProbe.timeoutSeconds=1,livenessProbe.periodSeconds=5 -n $NS bitnami/zookeeper
  
  while [ "$(kubectl get pods -lapp.kubernetes.io/name=zookeeper -n $NS -o jsonpath='{.items[*].status.containerStatuses[0].ready}')" != "true" ]
  do
    sleep 5
    echo "Waiting for Zookeeper to be ready..."
  done

  cat k8s/deployment.yml | envsubst | kubectl apply -n $NS -f -
elif [[ $1 == "down" ]]; then 
  helm uninstall zookeeper -n $NS || true
  helm repo remove bitnami || true
  cat k8s/deployment.yml | envsubst | kubectl delete -n $NS -f -
  kubectl delete namespace $NS
elif [[ $1 == "apply" ]]; then
  cat k8s/deployment.yml | envsubst | kubectl apply -n $NS -f -
else
  echo "run ./cluster.sh up | down"
fi
