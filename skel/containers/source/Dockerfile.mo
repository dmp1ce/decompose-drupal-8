FROM dmp1ce/php-fpm-drupal:5
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Install rsync
RUN apt-get update -yq && apt-get install -yq --no-install-recommends rsync && \
apt-get clean && \

# Create hostuser
groupadd -g {{PROJECT_HOST_GROUPID}} -o hostuser && \
useradd -m -u {{PROJECT_HOST_USERID}} -g {{PROJECT_HOST_GROUPID}} hostuser && \

# Store composer cache to prevent unnecessary downloads
su -c 'install -dm777 /home/hostuser/.composer' hostuser

# Copy all the source
COPY ./ {{PROJECT_BUILD_PATH}}/docker_build_context

# Fix ownership
RUN chown -R {{PROJECT_HOST_USERID}}:{{PROJECT_HOST_GROUPID}} {{PROJECT_BUILD_PATH}}/docker_build_context && \

# Create possible override directories and fix their ownership
chown -R {{PROJECT_HOST_USERID}}:{{PROJECT_HOST_GROUPID}} {{PROJECT_WEB_BUILD_PATH}} && \

# Make scripts executable
chmod +rx {{PROJECT_BUILD_PATH}}/docker_build_context/*.bash && sync && \

# Install Drush (latest)
cd /usr/local/src/drush && git checkout master --force && composer update && composer install && \

# Create Drupal build directory if it doesn't exist already
su -c 'mkdir -p {{PROJECT_WEB_BUILD_PATH}}' hostuser

USER hostuser
