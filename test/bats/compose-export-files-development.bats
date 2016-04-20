#!/usr/bin/env bats

# These tests build the Docker Compose containers and verify their functionality.
#
# Order of these tests is important because they build up the project, test some things and then cleanup. The reason for this is because building the project takes so long. Every tests building the project would take such a long time that it wouldn't be worth running the tests frequently.

load "$BATS_TEST_DIRNAME/bats_functions.bash"

# Production tests
@test "[development] File import and export works" {
  skip "Waiting to implement export_files process. #2102 in redmine."
  cd "$WORKING"

  # Build
  run decompose build
  echo "$output"
  [ "$status" -eq 0 ]

  # Start up
  run decompose up
  echo "$output"
  [ "$status" -eq 0 ]

  # Import test
  mkdir tmp_files
  touch tmp_files/hello{1,2,3,4,5}
  echo "Some content" >> tmp_files/content.txt

  run decompose import_files tmp_files
  echo "$output"
  [ "$status" -eq 0 ]

  # Recreate containers 
  docker-compose rm -f
  run decompose up
  echo "$output"
  [ "$status" -eq 0 ]

  # Run 'decompose export_files' without error
  run decompose export_files tmp_files_export
  echo "$output"
  [ "$status" -eq 0 ]

  # Verify the files were preserved and exported.
  [ -f tmp_files_export/content.txt ]
}

@test "[development] Stop project" {
  cd "$WORKING"
  decompose --build
  docker-compose stop
  decompose stop_nginx_proxy
}
@test "[development] Remove project" {
  skip "Not needed because nginx_proxy is never created by the test above because it is skipped also"
  cd "$WORKING"
  decompose --build
  docker-compose rm -f -v
  docker rm nginx_proxy
}

function setup() {
  setup_testing_environment

  # Switch to development element
  echo 'PROJECT_ENVIRONMENT="development"' >> "$WORKING/.decompose/elements"
}

function teardown() {
  teardown_testing_environment
}

# vim:syntax=sh tabstop=2 shiftwidth=2 expandtab
