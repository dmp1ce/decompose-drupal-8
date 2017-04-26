#!/bin/bash

source_dir=$1

# Make if core isn't built
if [ -f "${source_dir}/composer.json" ] &&
     [ ! -f "${source_dir}/{{PROJECT_WEB_DIRNAME}}/index.php" ]; then
  cd "${source_dir}"
  composer install
  {{#PROJECT_COMPOSER_UPDATE}}
  composer update
  composer update # If drupal is updated, then this update will update modules
  {{/PROJECT_COMPOSER_UPDATE}}
fi

# vim: syntax=sh
