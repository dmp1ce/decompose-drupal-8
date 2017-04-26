#!/bin/bash

{{#PRODUCTION}}
# Get time stamp
timestamp=$(date +%s)

# Move build to release volume.
shopt -s dotglob nullglob
mkdir {{PROJECT_RELEASES_PATH}}/${timestamp}
mv {{PROJECT_BUILD_PATH}}/build/* {{PROJECT_RELEASES_PATH}}/${timestamp}/

echo "Release created a location '{{PROJECT_RELEASES_PATH}}/${timestamp}'"
{{/PRODUCTION}}
{{#DEVELOPMENT}}
echo "Not creating a release for development."
{{/DEVELOPMENT}}
sleep 1
