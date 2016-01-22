php:
  build: containers/php/.
  volumes_from:
    - source
    - data
  links:
    - db
  environment:
    TERM: dumb
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
nginx:
  build: containers/nginx/.
  links:
    - php
  volumes_from:
    - source
    - data
  environment:
    - VIRTUAL_HOST={{PROJECT_NGINX_PROXY_VIRTUAL_HOSTS}}
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
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}
# Data containers
source:
  build: containers/source/.
  volumes:
    - {{#DEVELOPMENT}}{{PROJECT_SOURCE_HOST_PATH}}{{/DEVELOPMENT}}{{#PRODUCTION}}{{PROJECT_NAMESPACE}}_build{{/PRODUCTION}}:{{PROJECT_BUILD_PATH}}/build
    - {{PROJECT_NAMESPACE}}_releases:{{PROJECT_RELEASES_PATH}}
    {{#DEVELOPMENT}}- {{PROJECT_SOURCE_HOST_PATH}}/../modules:{{PROJECT_BUILD_PATH}}/build/sites/all/modules{{/DEVELOPMENT}}
    {{#DEVELOPMENT}}- {{PROJECT_SOURCE_HOST_PATH}}/../themes:{{PROJECT_BUILD_PATH}}/build/sites/all/themes{{/DEVELOPMENT}}
    {{#DEVELOPMENT}}- {{PROJECT_SOURCE_HOST_PATH}}/../libraries:{{PROJECT_BUILD_PATH}}/build/sites/all/libraries{{/DEVELOPMENT}}
  command: echo "{{PROJECT_ENVIRONMENT}} source. Doing nothing."
  labels:
    - "data_container=true"
data:
  build: containers/data/.
  command: "true"
  labels:
    - "data_container=true"
# Backup
backup:
  build: containers/backup/.
  command: "/home/duply/backup_service"
  volumes_from:
    - data
  links:
    - db
{{#PRODUCTION}}
  restart: always
{{/PRODUCTION}}

# vi: set tabstop=2 expandtab syntax=yaml:
