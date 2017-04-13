#!/usr/bin/env bats

# These tests build the Docker Compose containers and verify their functionality.
#
# Order of these tests is important because they build up the project, test some things and then cleanup. The reason for this is because building the project takes so long. Every tests building the project would take such a long time that it wouldn't be worth running the tests frequently.

load "$BATS_TEST_DIRNAME/bats_functions.bash"

# Production tests
@test "[production] 'decompose build' builds containers without error" {
  cd "$WORKING"
  run decompose build

  echo "$output"
  [ "$status" -eq 0 ]
}

@test "[production] 'decompose up' starts containers without error" {
  cd "$WORKING"
  decompose --build
  run decompose up

  echo "$output"
  [ "$status" -eq 0 ]
}

@test "[production] Recreating project doesn't create new volumes" {
  cd "$WORKING"
  local volume_count=$(docker volume ls | wc -l)

  decompose --build
  decompose up

  local new_volume_count=$(docker volume ls | wc -l)

  [ "$volume_count" -eq "$new_volume_count" ]
}

@test "[production] Changing PROJECT_SOURCE_PATH doesn't break build for production" {
  cd "$WORKING"

  sed -i".tmp" 's/PROJECT_SOURCE_PATH="source\/drupal"/PROJECT_SOURCE_PATH="source\/httpdocs"/g' "$WORKING/elements" \
    && rm "$WORKING/elements.tmp"
  cat "$WORKING/elements"
  mv "$WORKING/containers/source/source/drupal" "$WORKING/containers/source/source/httpdocs"

  run decompose build
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "[production] Stop project" {
  cd "$WORKING"
  decompose --build
  docker-compose stop
  decompose stop_nginx_proxy
}

@test "[production] Remove project" {
  cd "$WORKING"
  decompose --build
  docker-compose rm -f -v
  docker rm nginx_proxy
}

function setup() {
  setup_testing_environment
}

function teardown() {
  teardown_testing_environment
}

# vim:syntax=sh tabstop=2 shiftwidth=2 expandtab
