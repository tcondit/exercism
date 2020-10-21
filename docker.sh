#!/usr/bin/env sh

set -e

. ./utils.sh

app_name=$0
command=$1

# Adapted from https://unix.stackexchange.com/a/353639/244926. It works for now.
#
for argument in "$@"
do
    key=$(echo "$argument" | cut -f1 -d=)
    value=$(echo "$argument" | cut -f2 -d=)
    case "$key" in
            --package-name)     package_name="${value}" ;;
            --package-version)  package_version="${value}" ;;
            *)
    esac
    unset key value
done


# TODO Consider saving to environment variables the first time they're seen.
#
check_package_info() {
  check_package_name
  check_package_version
}
check_package_name() {
  check_required "${package_name}" || die "Argument '--package-name' is required"
}
check_package_version() {
  check_required "${package_version}" || die "Argument '--package-version' is required"
}


# Grants Docker access to PyPI on Artifactory
# Comments:
# 1. Avoids writing user's Artifactory API key to "docker history".
# 2. File is removed from the image after "pip install" finishes.
# 3. File is removed from host filesystem before ${app_name} finishes.
# 4. File name is mangled to avoid conflicts or deleting the wrong thing.
#
copy_pip_config() {
  if [ -r "$HOME/.pip/pip.conf" ]; then
    tmp="$HOME/.pip/pip.conf"
  elif [ -r "$HOME/.config/pip/pip.conf" ]; then
    tmp="$HOME/.config/pip/pip.conf"
  else
    # Assume this is successful. However, it shouldn't be necessary, as it's
    # called in the Travis config.
    bash "./write_pip_config.sh"
    tmp="$HOME/.pip/pip.conf"
  fi
  pip_config="${app_name}_pip.conf"
  echo "Copying ${tmp} to ${pip_config}"
  cp "${tmp}" "${pip_config}" || die "Failed to open pip.conf"
  unset tmp
}


# Revokes Docker access to PyPI on Artifactory
#
rm_pip_config() {
  echo Removing "${pip_config}"
  rm "${pip_config}"
  unset pip_config
}


build_docker_dev() {
  check_package_info
  copy_pip_config
  check_docker_image_name
  check_artifactory_creds
  docker build -t "${DOCKER_IMAGE_NAME}" \
          --build-arg pip_config="${pip_config}" \
          --build-arg package_name="${package_name}" \
          --build-arg package_version="${package_version}" \
          --build-arg artifactory_username="${ARTIFACTORY_USERNAME}" \
          --build-arg artifactory_password="${ARTIFACTORY_PASSWORD}" .
}


check_image() {
  version=$(docker container run \
          --hostname "$DOCKER_IMAGE_NAME" \
          --tty "$DOCKER_IMAGE_NAME" \
          python -c "import smartsegmentsml.utils.load; print(smartsegmentsml.utils.load.version())")
  echo "SmartSegments version ${version}"
}


# CAUTION: Not certain, but it looks like I can overwrite images.
#
push_image() {
  check_package_info
  check_artifactory_creds
  check_artifactory_domain
  check_docker_image_name
  echo "Pushing ${DOCKER_IMAGE_NAME}"
  target_image="${ARTIFACTORY_DOMAIN}/${DOCKER_IMAGE_NAME}:${package_version}"
  docker tag "${DOCKER_IMAGE_NAME}" "${target_image}"
  docker push "${target_image}"
  unset target_image
}


dockerfile_version() {
  grep "package_version=" "./Dockerfile" > tmpfile
  tmp=$(cat tmpfile) && rm tmpfile
  echo ${tmp} | cut -f2 -d= > tmpfile
  requested=$(cat tmpfile) && rm tmpfile
}


# Look for a Docker image on Artifactory with the given package_name and
# package_version. Utility function.
#
image_versions() {
  check_package_info
#  local cmd tmp
  artifactory_base_domain="brightloomxray.jfrog.io"
  docker_repository="docker-data-dev"
  retval="false"
  cmd="curl -u ${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD} \
          -sSf https://${artifactory_base_domain}/artifactory/api/docker/${docker_repository}/v2/${package_name}/tags/list"
  ${cmd} > tmpfile
  image_versions=$(cat tmpfile)
  _jq=$(which jq)
  echo ${image_versions} | ${_jq} '.tags[]' > tmpfile2
  image_versions=$(tr '\n' ' ' < tmpfile2)
  rm tmpfile tmpfile2
}


# Check if there's a Docker image in Artifactory that matches the Dockerfile.
# Comments:
# 1. The package_version ARG in the repo's Dockerfile triggers updates.
# 2. If that version is not in Artifactory, create and push a new image.
# 3. This also triggers updating the Databricks job configs.
# 4. Finally, we reset or create the Databricks jobs.
#
# Caveat:
# 1. If the versions do match, Databricks jobs will not be updated, even if
# they're not also up to date.
#
up_to_date() {
  # TODO Get package_name and package_version from Dockerfile
  check_package_version

  dockerfile_version
  image_versions
  # In the absense of other information, update the image.
  up_to_date=1
  echo "requested: ${requested}"
  echo "found: ${image_versions}"
  for image in ${image_versions}
  do
    if [ "echo $image | grep $requested" ]; then
      up_to_date=0
      break
    fi
  done
  if [ "${requested}" = "${package_version}" ] \
          && [ -n "${requested}" ] \
          && [ -n "${package_version}" ]; then
    retval=0
  fi
  return "${up_to_date}"
}


update_image() {
  [ up_to_date ] && echo "up to date" && exit || echo "not up to date"

#    build_docker_dev
#    check_image
#    find_image
#    up_to_date
#    push_image
}


case "${command}" in
  login) docker_login;;
  build_dev) build_docker_dev;;
  check_image) check_image;;
  find_image) find_image;;
  up_to_date) up_to_date;;
  update_image) update_image;;
  dockerfile_version ) dockerfile_version;;
  image_versions) image_versions;;
  push) push_image;;
  *) usage ;;
esac
