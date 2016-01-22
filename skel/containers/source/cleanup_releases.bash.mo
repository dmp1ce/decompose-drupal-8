#!/bin/bash

# Remove all releases except the current
preserve_dir=$(readlink -f {{PROJECT_CURRENT_RELEASE_PATH}})
for dir_path in "{{PROJECT_RELEASES_PATH}}"/*; do
  if [ "$preserve_dir" == "$dir_path" ] || [ "{{PROJECT_CURRENT_RELEASE_PATH}}" == "$dir_path" ]; then
    continue
  fi
  echo "Deleting $dir_path"
  rm -rf "$dir_path"
done
