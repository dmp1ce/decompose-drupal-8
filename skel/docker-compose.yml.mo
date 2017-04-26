php:
  build: containers/php/.
  volumes_from:
    - source
    - files
  links:
    - db
  environment:
    TERM: dumb
  log_driver: "{{PROJECT_DOCKER_LOG_DRIVER}}"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
nginx:
  build: containers/nginx/.
  links:
    - php
  volumes_from:
    - source
    - files
  environment:
    - VIRTUAL_HOST={{PROJECT_NGINX_PROXY_VIRTUAL_HOSTS}}
{{#PROJECT_LETSENCRYPT}}
    - LETSENCRYPT_HOST={{PROJECT_NGINX_PROXY_VIRTUAL_HOSTS}}
    - LETSENCRYPT_EMAIL={{PROJECT_LETSENCRYPT_EMAIL}}
{{/PROJECT_LETSENCRYPT}}
  log_driver: "{{PROJECT_DOCKER_LOG_DRIVER}}"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
db:
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: {{PROJECT_DB_ROOT_PASSWORD}}
    MYSQL_USER: {{PROJECT_DB_USER}}
    MYSQL_PASSWORD: {{PROJECT_DB_PASSWORD}}
    MYSQL_DATABASE: {{PROJECT_DB_DATABASE}}
    TERM: dumb
  log_driver: "{{PROJECT_DOCKER_LOG_DRIVER}}"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
drupal_cron:
  build: containers/php/.
  volumes_from:
    - source
    - files
  links:
    - db
  command: /opt/cron_service
  environment:
    TERM: dumb
  log_driver: "{{PROJECT_DOCKER_LOG_DRIVER}}"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
# Data containers
source:
  build: containers/source/.
  volumes:
    - {{PROJECT_NAMESPACE}}_composer_cache:/home/hostuser/.composer
    - {{PROJECT_NAMESPACE}}_releases:{{PROJECT_RELEASES_PATH}}
    - {{PROJECT_NAMESPACE}}_build:{{PROJECT_BUILD_PATH}}/build
{{#DEVELOPMENT}}
    # Uncomment to enable overrides
    #- {{PROJECT_SOURCE_HOST_PATH}}:{{PROJECT_WEB_BUILD_PATH}}
    #- {{PROJECT_SOURCE_HOST_PATH}}/../modules:{{PROJECT_WEB_BUILD_PATH}}/sites/all/modules
    #- {{PROJECT_SOURCE_HOST_PATH}}/../themes:{{PROJECT_WEB_BUILD_PATH}}/sites/all/themes
    #- {{PROJECT_SOURCE_HOST_PATH}}/../libraries:{{PROJECT_WEB_BUILD_PATH}}/sites/all/libraries
    #- {{PROJECT_SOURCE_HOST_PATH}}/../config:{{PROJECT_BUILD_PATH}}/build/config
    #- {{PROJECT_SOURCE_HOST_PATH}}/../migration:{{PROJECT_BUILD_PATH}}/build/migration
{{/DEVELOPMENT}}
  command: "true"
  log_driver: "{{PROJECT_DOCKER_LOG_DRIVER}}"
  labels:
    - "data_container=true"
files:
  image: busybox
  command: echo "files container. Doing nothing."
  volumes:
    - {{PROJECT_NAMESPACE}}_public_files:/app/files/public
    - {{PROJECT_NAMESPACE}}_private_files:/app/files/private
  labels:
    - "data_container=true"
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
# Backup
backup:
  build: containers/backup/.
  command: "/home/duply/backup_service"
  volumes_from:
    - files
  links:
    - db
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}

# vi: set tabstop=2 expandtab syntax=yaml:
