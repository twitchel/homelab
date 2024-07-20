#!/usr/bin/env bash

echo_task() {
  printf "\033[0;34m--> %s\033[0m\n" "$*"
}

error() {
  printf "\033[0;31m%s\033[0m\n" "$*" >&2
}

### Pre-check Functions
check_application_installed() {
  local exitCode=0
  local command=$1
  if ! command -v $command > /dev/null; then
    error "$command not found, please install using your local machine package manager"
    exitCode=1
  else
    echo_task "$command is already installed"
  fi

  echo $exitCode
}

check_dependencies_installed() {
  local exitCode=0
  dependencies=("jq" "kubectl" "k3sup")

  for dependency in "${dependencies[@]}"; do
    echo $dependency
    if ! command -v $dependency > /dev/null; then
        error "$dependency not found, please install using your local machine package manager"
        exitCode=1
      else
        echo_task "$dependency is already installed"
      fi
  done

  if [[ $exitCode -ne 0 ]]; then
    exit 1
  fi
}