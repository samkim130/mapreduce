#!/bin/bash

NS="ws1"

if [[ -z $1 || -z $2 ]]; then
  printf "run ./scale.sh [deployment] [replicas]\n\tdeployment = master | worker | master-fail | worker-fail | proxy\n\treplicas = 0 ... N\n\texample: ./scale.sh master 3\n"
  exit
fi

DEPLOYMENT="mr-$1"
REPLICAS=$2

kubectl scale --replicas=$REPLICAS -n $NS deployment $DEPLOYMENT
kubectl wait deployment -n $NS --for condition=Available=True --timeout=90s $DEPLOYMENT
