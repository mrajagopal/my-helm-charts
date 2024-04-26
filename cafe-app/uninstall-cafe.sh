#!/bin/bash
set -u
COUNT=${1}
NAME=${2}

for ((i = 0; i < "${COUNT}"; i++)) {

    HELM_INSTALL_NAME="app-${NAME}-${i}"
    helm uninstall ${HELM_INSTALL_NAME} 
}

