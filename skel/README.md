# My Project

Example documentation on using Drupal 8 as a development environment

# Setup

1. Get the source: `git clone --recursive git@source.com:myproject.git myproject`
2. Create `.decompose/elements` file: `cp .decompose/environment/skel/.decompose/elements .decompose`
3. Edit the `.decompose/elements`. For development you'll probably want to change (or add) the elements:
	- `PROJECT_NGINX_VIRTUAL_HOST`
	- `PROJECT_NGINX_DEFAULT_HOST`
	- `PROJECT_NAMESPACE`
4. Add your site `VIRTUAL_HOST` to `/etc/hosts` so you'll be able to see the site from your host.
5. Build containers: `decompose build`
