#!/usr/bin/env bash
#
# [SYNOPSIS]
# this script will build the docker image
# the docker image uses the same env variables 
# that exists in github actions pipeline
# and this script feeds it into the build pipeline
# run it with --help flag to learn more
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export DEBIAN_FRONTEND=noninteractive
function string_contains() {
  local -r haystack="$1"
  local -r needle="$2"
  [[ "$haystack" == *"$needle"* ]]
}
function string_multiline_contains() {
  local -r haystack="$1"
  local -r needle="$2"
  echo "$haystack" | grep -q "$needle"
}
function string_to_uppercase() {
  local -r str="$1"
  echo "$str" | awk '{print toupper($0)}'
}
function string_strip_prefix() {
  local -r str="$1"
  local -r prefix="$2"
  echo "${str#$prefix}"
}
function string_strip_suffix() {
  local -r str="$1"
  local -r suffix="$2"
  echo "${str%$suffix}"
}
function string_is_empty_or_null() {
  local -r response="$1"
  [[ -z "$response" || "$response" == "null" ]]
}
function string_colorify() {
  local -r color_code="$1"
  local -r input="$2"
  echo -e "\e[1m\e[$color_code"m"$input\e[0m"
}
function string_blue() {
  local -r color_code="34"
  local -r input="$1"
  echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_yellow() {
  local -r color_code="93"
  local -r input="$1"
  echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_green() {
  local -r color_code="32"
  local -r input="$1"
  echo -e "$(string_colorify "${color_code}" "${input}")"
}
function string_red() {
  local -r color_code="31"
  local -r input="$1"
  echo -e "$(string_colorify "${color_code}" "${input}")"
}
function assert_not_empty() {
  local -r arg_name="$1"
  local -r arg_value="$2"
  local -r reason="$3"
  if [[ -z "$arg_value" ]]; then
    log_error "'$arg_name' cannot be empty. $reason"
    exit 1
  fi
}
function log() {
    local -r level="$1"
    local -r message="$2"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script_name="$(basename "$0")"
    local color
    case "$level" in
    INFO)
        color="string_green"
        ;;
    WARN)
        color="string_yellow"
        ;;
    ERROR)
        color="string_red"
        ;;
    esac
    echo >&2 -e "$(${color} "${timestamp} [${level}] ==>") $(string_blue "[$script_name]") ${message}"
}
function log_info() {
    local -r message="$1"
    log "INFO" "$message"
}
function log_warn() {
    local -r message="$1"
    log "WARN" "$message"
}
function log_error() {
    local -r message="$1"
    log "ERROR" "$message"
}

function help() {
    echo
    echo "Usage: [$(basename "$0")] [OPTIONAL ARG] [COMMAND | COMMAND <FLAG> <ARG>]"
    echo
    echo
    echo -e "[Synopsis]:\tbuilds/tags/pushes all docker images in a subdirectory through recursive search."
    echo
    echo "Optional Flags:"
    echo
    echo -e "  --root-dir\t\troot directory to search fo *Dockerfile.Default:'$PWD'"
    echo -e "  --push\t\tpushes the image to docker hub after build."
    echo
    echo "Example:"
    echo
    echo "  "$0" \\"
    echo "      --root-dir 'docker' \\"
    echo "      --push"
    echo
}

function main() {
    if ! command -v "docker" >/dev/null ; then
        log_error "'docker' was not found in PATH"
        return 1
    fi
    if ! command -v "git" >/dev/null ; then
        log_error "'git' was not found in PATH"
        return 1
    fi
    local ROOT_DIR="$PWD"
    local PUSH=false
    while [[ $# -gt 0 ]]; do
      local key="$1"
      case "$key" in
        --root-dir)
          ROOT_DIR="$2"
          shift
        ;;
        --push)
          PUSH=true
#          if [ ! -r "~/.docker/config.json"  ] ; then
#            log_error "login to docker before trying to push the image."
#            exit 1
#          fi
          docker system prune -f
          #docker images -q | xargs -I {} -P $(nproc) docker rmi -f {}
        ;;
        *)
          help
          exit 1
        ;;
      esac
      shift
    done
    assert_not_empty "PUSH" "$PUSH" "required variable."
    assert_not_empty "ROOT_DIR" "$ROOT_DIR" "required variable"
    assert_not_empty "GITHUB_ACTOR" "$GITHUB_ACTOR" "required variable. set it with git config --global user.name <user name>"
    assert_not_empty "GITHUB_TOKEN" "$GITHUB_TOKEN" "required variable. set it by running 'echo \"https://$(git config user.name):<github token>@github.com\" > ~/.git-credentials'"
    assert_not_empty "GITHUB_REPOSITORY" "$GITHUB_REPOSITORY" "required variable"
    assert_not_empty "GITHUB_REPOSITORY_OWNER" "$GITHUB_REPOSITORY_OWNER" "required variable"
    while read image; do 
      BUILD_DIR=$(dirname "$image")
      NAME=$(basename $BUILD_DIR)
      pushd $BUILD_DIR > /dev/null 2>&1
      tags=("latest")
      if [ -r .tags.ini ]; then
        tags=()
        for tag in $(cat .tags.ini | sed -e '/^#/d' -e '/^$/d'); do
          tags+=("$tag")
        done
      fi
      for tag in "${tags[@]}"; do
        log_info "building '$GITHUB_REPOSITORY/$NAME:$tag'"
        GIT_TAG="master"
        if [ "$tag" != "latest" ]; then
          GIT_TAG="$tag"
        fi
        docker build \
          --build-arg GIT_TAG="$GIT_TAG" \
          --build-arg GITHUB_ACTOR=$GITHUB_ACTOR \
          --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
          --build-arg GITHUB_REPOSITORY=$GITHUB_REPOSITORY \
          --build-arg GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER \
          --tag "$GITHUB_REPOSITORY/$NAME:$tag" \
          .
        if [ "$PUSH" = true ] ; then
          log_info "pushing '$GITHUB_REPOSITORY/$NAME:$tag'"
          docker push "$GITHUB_REPOSITORY/$NAME:$tag"
        fi
      done
      popd > /dev/null 2>&1
    done < <( find $ROOT_DIR -type f -name '*Dockerfile')
    docker system prune -f
#    if [ "$PUSH" = true ] ; then
#      # [NOTE] => making sure build user is logging in to github repository
#      docker image list --format "{{.Repository}}:{{.Tag}}" | xargs -I {} docker push {}
#    fi
    exit $?
}

if [ -z "${BASH_SOURCE+x}" ]; then
    main "${@}"
    exit $?
else
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        main "${@}"
        exit $?
    fi
fi
