#!/bin/bash

# Include '.*' pattern in globbing. http://unix.stackexchange.com/a/6397/55139
shopt -s dotglob nullglob

# Always make drupal directory if it doesn't exist
mkdir -p {{PROJECT_WEB_BUILD_PATH}}

# Install and optionally update Drupal
{{PROJECT_BUILD_PATH}}/docker_build_context/make.bash "{{PROJECT_BUILD_PATH}}/docker_build_context/{{PROJECT_COMPOSER_PATH}}"

{{#PRODUCTION}}
# Update all the souce in the build volume
echo "Updating source in shared build volume"

rm -rf {{PROJECT_WEB_BUILD_PATH}}/*
cp -r {{PROJECT_BUILD_PATH}}/docker_build_context/{{PROJECT_SOURCE_PATH}}/* {{PROJECT_WEB_BUILD_PATH}}

overrides_to_add=( 'themes' 'modules' 'libraries' )

mkdir -p {{PROJECT_WEB_BUILD_PATH}}/sites/all
for override in "${overrides_to_add[@]}"; do
  if [ -d "{{PROJECT_BUILD_PATH}}/docker_build_context/source/${override}" ]; then
    cp -r {{PROJECT_BUILD_PATH}}/docker_build_context/source/${override} {{PROJECT_WEB_BUILD_PATH}}/sites/all
  fi
done

# Copy config
mkdir -p {{PROJECT_BUILD_PATH}}/build/config
cp -r {{PROJECT_BUILD_PATH}}/docker_build_context/source/config/* {{PROJECT_BUILD_PATH}}/build/config
{{/PRODUCTION}}

{{#DEVELOPMENT}}
echo "Updating source from docker_build_context."
echo "Configure 'exclude_build_sync.txt' to avoid overwriting"
rsync -r --exclude-from={{PROJECT_BUILD_PATH}}/docker_build_context/source/exclude_build_sync.txt \
  {{PROJECT_BUILD_PATH}}/docker_build_context/{{PROJECT_SOURCE_PATH}}/ {{PROJECT_WEB_BUILD_PATH}}
{{/DEVELOPMENT}}

# Copy Drupal generic overrides into Drupal core, such as version.txt
cp -rn {{PROJECT_BUILD_PATH}}/docker_build_context/source/drupal-override/* {{PROJECT_WEB_BUILD_PATH}}

chmod +w {{PROJECT_WEB_BUILD_PATH}}/sites/default
# Copy settings.php and services.yml
cp -f {{PROJECT_BUILD_PATH}}/docker_build_context/source/{settings.php,services.yml} {{PROJECT_WEB_BUILD_PATH}}/sites/default

# Create files symlink
ln -sf /app/files/public {{PROJECT_WEB_BUILD_PATH}}/sites/default/files
ln -sf /app/files/private {{PROJECT_WEB_BUILD_PATH}}/sites/default/private
chmod -w {{PROJECT_WEB_BUILD_PATH}}/sites/default

{{#DEVELOPMENT}}
# Don't worry about chmod failing for development.
exit 0
{{/DEVELOPMENT}}

# vim: syntax=sh
