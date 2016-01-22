#FROM busybox
FROM dmp1ce/php-fpm-drupal
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Install Drush (latest)
RUN cd /usr/local/src/drush && \
git checkout master && \
composer install

# Copy all the source 
COPY ./ {{PROJECT_BUILD_PATH}}/docker_build_context

# Make scripts executable
# Download Drupal source
RUN chmod +rx {{PROJECT_BUILD_PATH}}/docker_build_context/*.bash && \
{{PROJECT_BUILD_PATH}}/docker_build_context/make.bash "{{PROJECT_BUILD_PATH}}/docker_build_context/source/drupal"
