#!/bin/bash

set -e

mkdir -p ~/.pip

if [ -z "${ARTIFACTORY_USERNAME}" ]; then
	echo "Environment variable ARTIFACTORY_USERNAME not set."
	#exit 1
fi

if [ -z "${ARTIFACTORY_PASSWORD}" ]; then
	echo "Environment variable ARTIFACTORY_PASSWORD not set."
	#exit 1
fi

cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@your-company.jfrog.io/artifactory/api/pypi/pypi/simple
EOF
