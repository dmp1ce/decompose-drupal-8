php:
  build: containers/php/.
  volumes_from:
    - source
    - files
  links:
    - db
  environment:
    TERM: dumb
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
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
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
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
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
# Data containers
source:
  build: containers/source/.
  volumes:
    - {{PROJECT_NAMESPACE}}_releases:{{PROJECT_RELEASES_PATH}}
{{#PRODUCTION}}
    - {{PROJECT_NAMESPACE}}_build:{{PROJECT_BUILD_PATH}}/build
{{/PRODUCTION}}
{{#DEVELOPMENT}}
    - {{PROJECT_SOURCE_HOST_PATH}}:{{PROJECT_BUILD_PATH}}/build/drupal
    - {{PROJECT_SOURCE_HOST_PATH}}/../modules:{{PROJECT_BUILD_PATH}}/build/drupal/sites/all/modules
    - {{PROJECT_SOURCE_HOST_PATH}}/../themes:{{PROJECT_BUILD_PATH}}/build/drupal/sites/all/themes
    - {{PROJECT_SOURCE_HOST_PATH}}/../libraries:{{PROJECT_BUILD_PATH}}/build/drupal/sites/all/libraries
    - {{PROJECT_SOURCE_HOST_PATH}}/../config:{{PROJECT_BUILD_PATH}}/build/config
{{/DEVELOPMENT}}
  command: echo "{{PROJECT_ENVIRONMENT}} source. Doing nothing."
  labels:
    - "data_container=true"
  log_driver: {{PROJECT_DOCKER_LOG_DRIVER}}
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
  log_driver: "journald"
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}

# vi: set tabstop=2 expandtab syntax=yaml:
