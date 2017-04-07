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

@test "[production] 'decompose import_files' works without error" {
  cd "$WORKING"
  mkdir tmp_files
  touch tmp_files/hello{1,2,3,4,5}
  echo "Some content" >> tmp_files/content.txt

  decompose --build
  docker-compose ps
  run decompose import_files tmp_files

  echo "$output"
  [ "$status" -eq 0 ]
}

@test "[production] Recreate containers" {
  cd "$WORKING"

  # Recreate containers
  decompose --build
  docker-compose rm -f
  run decompose up
}

@test "[production] 'decompose export_files' exports from preserved volumes" {
  skip "Waiting to implement export_files. See #2102 in Redmine"
  cd "$WORKING"
  decompose --build

  # Run 'decompose export_files' without error
  run decompose export_files tmp_files
  echo "$output"
  [ "$status" -eq 0 ]

  # Verify the files were preserved and exported.
  [ -f tmp_files/content.txt ]
}

@test "[production] 'decompose export_files' cannot export into an existing directory" {
  cd "$WORKING"
  decompose --build

  # Run 'decompose export_files' into existing directory will cause errors
  run decompose export_files containers
  echo "$output"
  [ "$status" -eq 1 ]
}
@test "[production] 'decompose export_files' errors with no parameters" {
  cd "$WORKING"
  decompose --build

  run decompose export_files
  echo "$output"
  [ "$status" -eq 1 ]
}

# Development tests
@test "Switching to development mode doesn't break build" {
  skip "Switching from production to development is not a use case we currently need for export_files to work in"
  cd "$WORKING"

  # Switch to development element
  echo 'PROJECT_ENVIRONMENT="development"' >> "$WORKING/.decompose/elements"

  run decompose build

  echo "$output"
  [ "$status" -eq 0 ]
}
@test "'decompose up' starts containers without error for development when switched from production" {
  skip "Switching from production to development is not a use case we currently need for export_files to work in"
  cd "$WORKING"

  # Switch to development element
  echo 'PROJECT_ENVIRONMENT="development"' >> "$WORKING/.decompose/elements"

  decompose --build
  run decompose up

  echo "$output"
  [ "$status" -eq 0 ]
}
@test "[development] 'decompose export_files' exports from preserved volumes" {
  skip "Switching from production to development is not a use case we currently need for export_files to work in"
  cd "$WORKING"
  decompose --build

  # Switch to development element
  echo 'PROJECT_ENVIRONMENT="development"' >> "$WORKING/.decompose/elements"

  # Run 'decompose export_files' without error
  docker-compose run --rm php ls /app/build/build/drupal/sites/default/files
  run decompose export_files tmp_files
  echo "$output"
  [ "$status" -eq 0 ]

  # Verify the files were preserved and exported.
  [ -f tmp_files/content.txt ]
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
