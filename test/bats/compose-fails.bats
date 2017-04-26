#!/usr/bin/env bats

# Verify some build failure cases for Compose project.

load "$BATS_TEST_DIRNAME/bats_functions.bash"

@test "'decompose build' failures return error code" {
  skip "Waiting to implement proper 'build' process error codes. See #2101 in Redmine"
  cd "$WORKING"
  echo "Syntax error here!" >> docker-compose.yml.mo
  run decompose build

  echo "$output"
  [ "${lines[${#lines[@]}-1]}" == "Return code of '2' detected. Returning." ]
  [ "$status" -ne 0 ]
}

@test "Remove project" {
  cd "$WORKING"
  decompose --build
  docker-compose rm -f -v
}

function setup() {
  setup_testing_environment
}

function teardown() {
  teardown_testing_environment
}

# vim:syntax=sh tabstop=2 shiftwidth=2 expandtab
