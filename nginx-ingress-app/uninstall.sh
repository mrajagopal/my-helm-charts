#!/bin/bash
set -u 
COUNT=${1}
NAME=${2}

for ((i = 0; i < $1; i++)) {
  HELM_INSTALL_NAME=${NAME}-${i}
  NAMESPACE=${HELM_INSTALL_NAME}
  helm uninstall ${HELM_INSTALL_NAME} --namespace ${NAMESPACE} 
  kubectl delete ns ${NAMESPACE} --wait=false
}
