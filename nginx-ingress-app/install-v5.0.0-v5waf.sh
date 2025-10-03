#!/bin/bash
set -u

if ! command -v helm >/dev/null 2>&1; then
	echo "Error: 'helm' is not installed or not in PATH. Please install Helm before running this script."
	exit 1
fi

# Install PodMonitor CRD for NIC Pod Monitoring
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.85.0/stripped-down-crds.yaml

# Create PersistentVolume and PersistentVolumeClaim for App Protect WAF bundles
echo "Creating PersistentVolume and PersistentVolumeClaim for App Protect WAF..."
kubectl apply -f ./app-protect-pv.yaml

COUNT=${1}
NAME=${2}
CHART_VERSION=2.1.0
NIC_VERSION="5.0.0"
TAG="5.0.0-ubi"
read -sp 'Please enter JWT Token if using a private container registry: ' JWT_TOKEN
echo ""
read -sp 'Please enter license JWT: ' JWT_LICENSE
for ((i = 0; i < ${COUNT}; i++)) {
	HELM_INSTALL_NAME=${NAME}-${i}
	NAMESPACE=${HELM_INSTALL_NAME}
	INGRESS_CLASS_NAME=${NAMESPACE}
	kubectl create ns ${NAMESPACE}
	
	# Create the PVC in the namespace for App Protect WAF bundles
	kubectl apply -f ./app-protect-pv.yaml -n ${NAMESPACE}
	
	kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=$JWT_TOKEN --docker-password=none -n ${NAMESPACE}
	kubectl create secret generic license-token --from-literal=license.jwt=$JWT_LICENSE --type=nginx.com/license -n ${NAMESPACE}
#	helm install ${HELM_INSTALL_NAME} oci://ghcr.io/nginxinc/charts/nginx-ingress --version ${CHART_VERSION}  -f ./values.yaml --namespace ${NAMESPACE} --create-namespace --set controller.ingressClass.name="${INGRESS_CLASS_NAME}" --set controller.image.tag=${NIC_VERSION}
	helm install ${HELM_INSTALL_NAME} oci://ghcr.io/nginx/charts/nginx-ingress --version ${CHART_VERSION}  -f ./values-wafv5.yaml --namespace ${NAMESPACE} --create-namespace --set controller.ingressClass.name="${INGRESS_CLASS_NAME}" --set controller.image.tag=${TAG}
         helm install nic-podmon-${NAMESPACE} nic-podmon --namespace ${NAMESPACE}
}
