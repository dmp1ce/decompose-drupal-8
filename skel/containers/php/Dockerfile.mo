FROM dmp1ce/php-fpm-drupal:5
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Install Drush (latest)
RUN cd /usr/local/src/drush && \
git checkout master && \
composer install

# Use the default php.ini depending on $environment.
RUN cp /usr/src/php/php.ini-{{PROJECT_ENVIRONMENT}} /usr/local/etc/php/php.ini

# Add msmtp settings
COPY msmtp/msmtp_php /etc/msmtp_php
RUN chmod 600 /etc/msmtp_php && chown www-data:www-data /etc/msmtp_php && \
sed -i 's|;sendmail_path =$|sendmail_path = "{{PROJECT_SENDMAIL_PATH}}"|g' /usr/local/etc/php/php.ini

# disable mbstring.http_input and mbstring.http_output
RUN sed -i 's|;mbstring.http_input =$|mbstring.http_input = pass|g' /usr/local/etc/php/php.ini
RUN sed -i 's|;mbstring.http_output =$|mbstring.http_output = pass|g' /usr/local/etc/php/php.ini

# Set timezone
RUN sed -i 's|;date.timezone =$|date.timezone = "{{PROJECT_PHP_TIMEZONE}}"|g' /usr/local/etc/php/php.ini
# Increase memory limit
#RUN sed -i 's|memory_limit = 128M|memory_limit = 256M|g' /usr/local/etc/php/php.ini
# Increase pm.max_children value (For Drupal's features module)
#RUN sed -i 's|pm.max_children = 5|pm.max_children = 20|g' /usr/local/etc/php-fpm.conf

# Add mail_catch script
COPY mail_catch /opt/mail_catch
RUN chmod +x /opt/mail_catch

# Set working directory to Drupal
WORKDIR {{PROJECT_SOURCE_CONTAINER_PATH}}
