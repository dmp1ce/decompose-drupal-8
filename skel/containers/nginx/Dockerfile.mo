{{#PROJECT_DEBUG_NGINX}}
FROM esepublic/nginx-with-debug
{{/PROJECT_DEBUG_NGINX}}
{{^PROJECT_DEBUG_NGINX}}
FROM nginx:latest
{{/PROJECT_DEBUG_NGINX}}
MAINTAINER David Parrish <daveparrish@tutanota.com>

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
    supervisor \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Copy nginx config files
COPY default.conf /etc/nginx/conf.d/default.conf
{{#PROJECT_HTTP_SECURITY}}
COPY htpasswd /etc/nginx/htpasswd
{{/PROJECT_HTTP_SECURITY}}

# Add x_forward_proto $https map with following formating:
#     map $http_x_forwarded_proto $https {
#         https on;
#     }
RUN sed -i '/ #gzip  on/a\\n    map $http_x_forwarded_proto $proxyhttps {\n        https on;\n    }' /etc/nginx/nginx.conf

# Copy application scripts
COPY app/. /app/
COPY app/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /app/

# Change command to run supervisor instead of nginx
CMD ["/usr/bin/supervisord", "-c", "/app/supervisord.conf"]
