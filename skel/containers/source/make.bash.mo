#!/bin/bash

{{#PRODUCTION}}
echo "!!TODO!!"
echo "This is production, so build source cleanly."
{{/PRODUCTION}}

drupal_source_dir=$1
if [ ! -d "$drupal_source_dir" ]; then
  echo "Error! Drupal source directory does not exist." 
  exit 1
fi

# Make if make.yml exists
if [ -f "${drupal_source_dir}/make.yml" ]; then
  cd "${drupal_source_dir}"
  drush make -y make.yml
fi
