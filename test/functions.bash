#!/bin/bash

# Requires DIR global variable which identifies script directory.

function setup_testing_environment() {
  echo "Setting up Docker testing environment ..."
  # Create dind daemon with a mount to project.
  echo "DinD service"
  testing_env_build=$(docker run --privileged --name decompose-docker-drupal7-testing -d docker:dind)
  [ ["$?" == "1" ] && echo "$testing_env_build" ]

  # Build testing image
  echo "Tester image"
  local project_directory=$(readlink -f "$DIR/../")
  local tmp_tester_build="/tmp/decompose-docker-drupal-7-testing"
  # Copy volume so we can safely dereference symlinks
  # Create docker container for doing tests
  cp -rL "$project_directory/." "$tmp_tester_build"
  cp "$project_directory/test/Dockerfile.tester" "$tmp_tester_build/Dockerfile"
  local testing_env_build=$(docker build -t decompose-docker-drupal-7-testing-tester "$tmp_tester_build/.")

  [ "$?" == "1" ] && echo "$testing_env_build"
}

function run_tests() {
  local tester_image="docker run --rm --link decompose-docker-drupal7-testing:docker decompose-docker-drupal-7-testing-tester"
  local return_code=0

  echo "Running BATS tests"
  echo "Drupal 7 tests"
  $tester_image bats "/app/test/bats"
  local return_code+=$?

  #echo "Web library tests"
  #$tester_image bats "/app/skel/bats/web"
  #local return_code+=$?

  return $return_code
}

function teardown_testing_environment() {
  echo "Teardown Docker testing environment ..."
  echo "DinD service"
  testing_env_cleanup=$(docker rm -fv decompose-docker-drupal7-testing)
  [ "$?" == "1" ] && echo "$testing_env_cleanup"

  echo "decompose build environment"
  testing_env_cleanup=$(docker rmi -f decompose-docker-drupal-7-testing-tester)
  [ "$?" == "1" ] && echo "$testing_env_cleanup"
}
