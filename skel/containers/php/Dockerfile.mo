FROM dmp1ce/php-fpm-drupal:5
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Install Drush (latest)
RUN cd /usr/local/src/drush && \
git checkout master && \
composer update && composer install && \

# Use the default php.ini depending on $environment.
cp /usr/src/php/php.ini-{{PROJECT_ENVIRONMENT}} /usr/local/etc/php/php.ini

# Copy check_drupal
COPY check_drupal /opt/check_drupal

# Add msmtp settings
COPY msmtp/msmtp_php /etc/msmtp_php
RUN chmod 600 /etc/msmtp_php && chown www-data:www-data /etc/msmtp_php && \
sed -i 's|;sendmail_path =$|sendmail_path = "{{PROJECT_SENDMAIL_PATH}}"|g' /usr/local/etc/php/php.ini

# disable mbstring.http_input and mbstring.http_output
# Set timezone
# Fix raw post bug: https://www.drupal.org/node/2456025
RUN sed -i 's|;mbstring.http_input =$|mbstring.http_input = pass|g' /usr/local/etc/php/php.ini && \
  sed -i 's|;mbstring.http_output =$|mbstring.http_output = pass|g' /usr/local/etc/php/php.ini && \
  sed -i 's|;date.timezone =$|date.timezone = "{{PROJECT_PHP_TIMEZONE}}"|g' /usr/local/etc/php/php.ini && \
  sed -i 's|;always_populate_raw_post_data =.*$|always_populate_raw_post_data = -1|g' /usr/local/etc/php/php.ini

# Increase memory limit
#RUN sed -i 's|memory_limit = 128M|memory_limit = 256M|g' /usr/local/etc/php/php.ini
# Increase pm.max_children value (For Drupal's features module)
#RUN sed -i 's|pm.max_children = 5|pm.max_children = 20|g' /usr/local/etc/php-fpm.conf

# Add mail_catch script
# Create 'hostuser'
# Create temporary release path
COPY mail_catch /opt/mail_catch
RUN chmod +x /opt/mail_catch && \
groupadd -g {{PROJECT_HOST_GROUPID}} -o hostuser && \
useradd -m -u {{PROJECT_HOST_USERID}} -g {{PROJECT_HOST_GROUPID}} hostuser && \
mkdir -p {{PROJECT_CURRENT_RELEASE_PATH}}/{{PROJECT_WEB_DIRNAME}}

# Add cron_service script
COPY cron_service /opt/cron_service
RUN chmod +x /opt/cron_service

# Set working directory to Drupal
WORKDIR {{PROJECT_CURRENT_RELEASE_PATH}}/{{PROJECT_WEB_DIRNAME}}
