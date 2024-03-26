#!/bin/bash
set -u

for ((i = 0; i < "${1}"; i++)) {
#	helm install nginx-ingress-${i} oci://ghcr.io/nginxinc/charts/nginx-ingress --version 0.18.0 -f ./values.yaml --namespace nginx-ingress-${i} --create-namespace --set controller.ingressClass="nginx-ingress-${i}" --set controller.image.tag="3.2.0"
    helm install nic-${i} cafe-chart --set ingressClass.name="nginx-ingress-${i}" --set number=${i}
}

