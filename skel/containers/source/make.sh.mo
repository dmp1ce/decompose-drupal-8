#!/bin/bash

# Make if make.yml exists
if [ -f "{{PROJECT_SOURCE_CONTAINER_PATH}}/make.yml" ]; then
  cd "{{PROJECT_SOURCE_CONTAINER_PATH}}"
  drush make -y make.yml
fi
