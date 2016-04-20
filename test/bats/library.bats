#!/usr/bin/env bats

# Verify that library bats are generated from skeleton

load "$BATS_TEST_DIRNAME/bats_functions.bash"

@test "Web library bats exist" {
  skip "Not relevant any longer"
  cd "$WORKING"
  local number_of_bats=$(ls -alh bats/web/*.bats | wc -l)

  [ "$number_of_bats" -gt 0 ]
}

function setup() {
  setup_testing_environment
} 

function teardown() {
  teardown_testing_environment
}

# vim:syntax=sh tabstop=2 shiftwidth=2 expandtab
