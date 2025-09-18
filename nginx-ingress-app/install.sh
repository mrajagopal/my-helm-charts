#!/bin/bash
set -u

if ! command -v helm >/dev/null 2>&1; then
	echo "Error: 'helm' is not installed or not in PATH. Please install Helm before running this script."
	exit 1
fi

# Install PodMonitor CRD for NIC Pod Monitoring
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.85.0/stripped-down-crds.yaml

COUNT=${1}
NAME=${2}
CHART_VERSION=1.0.2
NIC_VERSION="3.3.2"
read -sp 'Please enter JWT Token if using a private container registry: ' JWT_TOKEN

for ((i = 0; i < ${COUNT}; i++)) {
	HELM_INSTALL_NAME=${NAME}-${i}
	NAMESPACE=${HELM_INSTALL_NAME}
	INGRESS_CLASS_NAME=${NAMESPACE}
	kubectl create ns ${NAMESPACE}
	kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=$JWT_TOKEN --docker-password=none -n ${NAMESPACE}
	helm install ${HELM_INSTALL_NAME} oci://ghcr.io/nginxinc/charts/nginx-ingress --version ${CHART_VERSION}  -f ./values.yaml --namespace ${NAMESPACE} --create-namespace --set controller.ingressClass.name="${INGRESS_CLASS_NAME}" --set controller.image.tag=${NIC_VERSION}
        helm install nic-podmon-${NAMESPACE} nic-podmon --namespace ${NAMESPACE}
}
