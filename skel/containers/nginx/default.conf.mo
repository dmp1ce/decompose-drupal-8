# Drupal 8 nginx config
# Reference: https://www.nginx.com/resources/wiki/start/topics/recipes/drupal/
server {
  server_name {{PROJECT_NGINX_VIRTUAL_HOST}};
  root {{PROJECT_CURRENT_RELEASE_PATH}}/drupal; ## <-- Your only path reference.
 
  location = /favicon.ico {
    log_not_found off;
    access_log off;
  }

  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
  }

  location = /version.txt {
    allow all;
    log_not_found off;
    access_log off;
  }
 
  # Very rarely should these ever be accessed outside of your lan
  location ~* \.(txt|log)$ {
    allow 192.168.0.0/16;
    deny all;
  }
 
  location ~ \..*/.*\.php$ {
    return 403;
  }
 
  # No no for private
  location ~ ^/sites/.*/private/ {
    return 403;
  }
 
  # Block access to "hidden" files and directories whose names begin with a
  # period. This includes directories used by version control systems such
  # as Subversion or Git to store control files.
  location ~ (^|/)\. {
    return 403;
  }
 
  location / {
    # This is cool because no php is touched for static content
    try_files $uri /index.php?$query_string;

{{#PROJECT_HTTP_SECURITY}}
    auth_basic  "Access Restricted";
    auth_basic_user_file htpasswd;
{{/PROJECT_HTTP_SECURITY}}
  }
 
  location @rewrite {
    rewrite ^/(.*)$ /index.php?q=$1;
  }

  # Don't allow direct access to PHP files in the vendor directory.
  location ~ /vendor/.*\.php$ {
    deny all;
    return 404;
  }
 
  # In Drupal 8, we must also match new paths where the '.php' appears in the middle,
  # such as update.php/selection. The rule we use is strict, and only allows this pattern
  # with the update.php front controller.  This allows legacy path aliases in the form of
  # blog/index.php/legacy-path to continue to route to Drupal nodes. If you do not have
  # any paths like that, then you might prefer to use a laxer rule, such as:
  #   location ~ \.php(/|$) {
  # The laxer rule will continue to work if Drupal uses this new URL pattern with front
  # controllers other than update.php in a future release.
  location ~ '\.php$|^/update.php' {
    fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
    #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $request_filename;
    fastcgi_intercept_errors on;
    fastcgi_param HTTPS $proxyhttps if_not_empty;
    fastcgi_pass php:9000;
  }

  # Fighting with Styles? This little gem is amazing.
  # This is for D7 and D8
  location ~ ^/sites/.*/files/styles/ {
    try_files $uri @rewrite;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires max;
    log_not_found off;
  }
}

{{#PROJECT_NGINX_VIRTUAL_HOST_ALTS}}
# Redirect alternative domain names.
server {
  server_name {{PROJECT_NGINX_VIRTUAL_HOST_ALTS}};
  # $scheme will get the http protocol
  # and 301 is best practice for tablet, phone, desktop and seo
  return 301 $scheme://{{PROJECT_NGINX_VIRTUAL_HOST}}$request_uri;
}
{{/PROJECT_NGINX_VIRTUAL_HOST_ALTS}}

# vim:syntax=nginx
