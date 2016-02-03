#!/bin/bash

drupal_source_dir=$1
if [ ! -d "$drupal_source_dir" ]; then
  echo "Error! Drupal source directory does not exist." 
  exit 1
fi

# Make if make.yml exists ( and drupal does not )
if [ -f "${drupal_source_dir}/make.yml" ] && [ ! -f "${drupal_source_dir}/index.php" ]; then
  cd "${drupal_source_dir}"
  chmod -f +w sites/default
  drush make -y make.yml
fi
