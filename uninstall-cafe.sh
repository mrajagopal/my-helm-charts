#!/bin/bash
set -u

for ((i = 0; i < "${1}"; i++)) {
    helm uninstall nic-${i} #cafe-chart --set ingressClass.name="nginx-ingress-${i}" --set number=${i}
}

