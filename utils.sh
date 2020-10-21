# shellcheck shell=sh
#
# The first line tells shellcheck that this script is intended to be sourced,
# not executed directly. This comment tells everyone else. Usage from the shell
# or in a script: . ./utils.sh

set -e

die() {
  echo "$1"
  exit 1
}

check_required() {
  if [ -n "${1}" ]; then
    return 0
  fi
  return 1
}

# TODO Check both vars before reporting back.
#
check_artifactory_creds() {
  check_required "${ARTIFACTORY_USERNAME}" || die "ARTIFACTORY_USERNAME is a required environment variable"
  check_required "${ARTIFACTORY_PASSWORD}" || die "ARTIFACTORY_PASSWORD is a required environment variable"
}

check_artifactory_domain() {
  check_required "${ARTIFACTORY_DOMAIN}" || \
          die "ARTIFACTORY_DOMAIN is a required environment variable\nExample: your-company.jfrog.io" 
}

check_databricks_access() {
  command databricks jobs list > /dev/null || die "Databricks CLI not working"
}

check_docker_image_name() {
  check_required "${DOCKER_IMAGE_NAME}" || die "DOCKER_IMAGE_NAME is a required environment variable"
}

docker_login() {
  check_artifactory_creds
  check_artifactory_domain
  docker login "${ARTIFACTORY_DOMAIN}" -u "${ARTIFACTORY_USERNAME}" -p "${ARTIFACTORY_PASSWORD}"
}
