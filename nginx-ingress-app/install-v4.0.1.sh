#!/bin/bash
set -u
COUNT=${1}
NAME=${2}
CHART_VERSION=2.0.1
NIC_VERSION="4.0.1"
TAG="4.0.1-ubi"
read -sp 'Please enter JWT Token if using a private container registry: ' JWT_TOKEN
read -sp 'Please enter license JWT: ' JWT_LICENSE
for ((i = 0; i < ${COUNT}; i++)) {
	HELM_INSTALL_NAME=${NAME}-${i}
	NAMESPACE=${HELM_INSTALL_NAME}
	INGRESS_CLASS_NAME=${NAMESPACE}
	kubectl create ns ${NAMESPACE}
	kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=$JWT_TOKEN --docker-password=none -n ${NAMESPACE}
	kubectl create secret generic license-token --from-literal=license.jwt=$JWT_LICENSE --type=nginx.com/license -n ${NAMESPACE}
	helm install ${HELM_INSTALL_NAME} oci://ghcr.io/nginx/charts/nginx-ingress --version ${CHART_VERSION}  -f ./values.yaml --namespace ${NAMESPACE} --create-namespace --set controller.ingressClass.name="${INGRESS_CLASS_NAME}" --set controller.image.tag=${TAG}
         helm install nic-podmon-${NAMESPACE} nic-podmon --namespace ${NAMESPACE}
}
