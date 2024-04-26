#!/bin/bash
set -u
COUNT=${1}
NAME=${2}

for ((i = 0; i < "${COUNT}"; i++)) {
    INGRESS_CLASS_NAME="${NAME}-${i}"
    HELM_INSTALL_NAME="app-${INGRESS_CLASS_NAME}"
    helm install ${HELM_INSTALL_NAME} cafe-chart --set ingressClass.name="${INGRESS_CLASS_NAME}" --set number=${i}
}

