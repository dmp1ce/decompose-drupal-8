#!/bin/bash

{{#PRODUCTION}}
# Sets the current release
latest_dir_name="0"
for dir_path in "{{PROJECT_RELEASES_PATH}}/"*; do
  # Skip current directory
  if [ "$dir_path" == "{{PROJECT_RELEASES_PATH}}/current" ]; then continue; fi

  dir_name=${dir_path##*/}
  if [ "$dir_name" -gt "$latest_dir_name" ]; then
    latest_dir_name=$dir_name
  fi
done 

if [ "$latest_dir_name" -gt "0" ]; then
  echo "Setting '{{PROJECT_RELEASES_PATH}}/$latest_dir_name' to the current release"
  ln -sfn {{PROJECT_RELEASES_PATH}}/$latest_dir_name {{PROJECT_CURRENT_RELEASE_PATH}}
else
  echo "Latest release directory was not found. Exiting." 1>&2
  exit 1
fi
{{/PRODUCTION}}
{{#DEVELOPMENT}}
echo "Setting '{{PROJECT_BUILD_PATH}}/build' to the current release"
ln -sfn {{PROJECT_BUILD_PATH}}/build {{PROJECT_CURRENT_RELEASE_PATH}}
{{/DEVELOPMENT}}

# vim: syntax=sh
