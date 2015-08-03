NGINX
=====

This role manages NGINX. 

Some Nginx configs that you can achieve with this role includes:
- vhost
- location
- upstream
- mailhost
- geo
- mappings

More details about available variables can be found in the defaults variables file
(defaults/main.yml).


## vHost Config

nginx\_vhost:  a list of vhost dict items. Each item results in a vhost config file.

```
nginx_vhost:
  - vhost:                         example.co.uk
    use_default_location:          true
    listen_port:                   443
    listen_options:                default_server
    ssl:                           true
    ssl_port:                      443
    ssl_key:                       /etc/ssl/private/ssl-cert-wildcard-example.co.uk.key
    ssl_cert:                      /etc/ssl/certs/ssl-cert-wildcard-example.co.uk.pem
    ssl_protocols:                 'TLSv1 TLSv1.1 TLSv1.2'
    proxy_pass:                    'https://example-apptier-lbs'
    proxy_read_timeout:            60
    ###proxy_set_header:              []
    proxy_cache:                   example_co_uk_cache
    proxy_cache_valid:             5m
    location_cfg_prepend:
    vhost_cfg_ssl_prepend:
      error_page:       '502 503 504 /503.html'
      real_ip_header:   'X-Forwarded-For'
      set_real_ip_from: '0.0.0.0/0'
  - vhost:                         example-admin..co.uk
    use_default_location:          true
    listen_port:                   443
    ssl:                           true
    ssl_port:                      443
    ssl_protocols:                 'TLSv1 TLSv1.1 TLSv1.2'
    ssl_key:                       /etc/ssl/private/ssl-cert-wildcard-example.co.uk.key
    ssl_cert:                      /etc/ssl/certs/ssl-cert-wildcard-example.co.uk.pem
    proxy_pass:                    'https://example-apptier-admin-lbs'
    proxy_read_timeout:            60
    vhost_cfg_ssl_prepend:
      error_page:       '502 503 504 /503.html'
      real_ip_header:   'X-Forwarded-For'
      set_real_ip_from: '0.0.0.0/0'
  - vhost:                         example-payments.co.uk
    use_default_location:          true
    enable:                        false
    listen_port:                   443
    ssl:                           true
    ssl_port:                      443
    ssl_protocols:                 'TLSv1 TLSv1.1 TLSv1.2'
    ssl_key:                       /etc/ssl/private/ssl-cert-wildcard-example.co.uk.key
    ssl_cert:                      /etc/ssl/certs/ssl-cert-wildcard-example.co.uk.pem
    proxy_pass:                    'https://example-apptier-services-lbs'
    proxy_read_timeout:            60
    vhost_cfg_ssl_prepend:
      error_page:       '502 503 504 /503.html'
      real_ip_header:   'X-Forwarded-For'
      set_real_ip_from: '0.0.0.0/0'
  - vhost:                         example-services.co.uk
    use_default_location:          true
    listen_port:                   443
    ssl:                           true
    ssl_port:                      443
    ssl_protocols:                 'TLSv1 TLSv1.1 TLSv1.2'
    ssl_key:                       /etc/ssl/private/ssl-cert-wildcard-example.co.uk.key
    ssl_cert:                      /etc/ssl/certs/ssl-cert-wildcard-example.co.uk.pem
    proxy_pass:                    'https://example-apptier-lbs'
    proxy_read_timeout:            60
    location_deny:                 [ all ]
    vhost_cfg_ssl_prepend:
      error_page:       '502 503 504 /503.html'
      real_ip_header:   'X-Forwarded-For'
      set_real_ip_from: '0.0.0.0/0'
```

**Note**: Each dict item in the nginx_vhost list must have a vhost key as this is 
the key that binds vhost and location configs.

## Location config

nginx\_location: A list of location dict items to be configured within vhosts.

**Note**: Each dict item in the nginx_location list must have a vhost key as this is 
the key that binds vhost and location configs.

```
config_nginx_location:  true
nginx_location:
  - location:              '= favicon.ico'
    vhost:                 'example.co.uk'
    www_root:              '/etc/nginx/errors/'
    ssl:                   true
    ssl_only:              true
  - location:              '/503.html'
    vhost:                 'example.co.uk'
    www_root:              '/etc/nginx/errors/'
    ssl:                   true
    ssl_only:              true
  - location:              '/503.html'
    vhost:                 'example-admin..co.uk'
    www_root:              '/etc/nginx/errors/'
    ssl:                   true
    ssl_only:              true
    index_files: []
  - location:              '/payment/notification'
    vhost:                 'example.co.uk'
    proxy_pass:            'https://example-apptier-lbs'
    proxy_read_timeout:    60
    location_allow:
      - 172.20.1.111
      - 194.168.223.139
      - 37.26.93.122
    location_deny:         [ all ]
    proxy_set_header:
      - 'Host $host'
      - 'X-Real-IP $remote_addr'
      - 'X-Forwarded-For $proxy_add_x_forwarded_for'
    ssl:                   true
    ssl_only:              true
  - location:              '= /services/notify'
    vhost:                 'example-services..co.uk'
    proxy_pass:            'https://example-apptier-services-lbs/services/notify'
    proxy_read_timeout:    60
    location_custom_cfg_prepend:
      if: "($ssl_client_verify != SUCCESS) {\n      return 403;\n      break;\n    }\n"
    ssl:                   true
    ssl_only:              true
  - location:              '/services/reports'
    vhost:                 'example-services..co.uk'
    proxy_pass:            'https://example-apptier-services-lbs/services/notify'
    proxy_read_timeout:    60
    location_custom_cfg_prepend:
      if: "($ssl_client_verify != SUCCESS) {\n      return 403;\n      break;\n    }\n"
    ssl:                   true
    ssl_only:              true
```

## Upstream

nginx\_upstream: A list of upstream dict items.

```
config_nginx_upstream:  true
nginx_upstream:
  - name: example-apptier-lbs
    members:
      - '172.20.1.199:443 max_fails=3 fail_timeout=5'
      - '172.20.1.198:443 max_fails=3 fail_timeout=5'
  - name: example-apptier-admin-lbs
    members:
      - '172.20.1.199:443 max_fails=3 fail_timeout=5'
      - '172.20.1.198:443 max_fails=3 fail_timeout=5'
  - name: example-apptier-services-lbs
    members:
      - '172.20.1.199:8443 max_fails=3 fail_timeout=5'
      - '172.20.1.198:8443 max_fails=3 fail_timeout=5'
```

## Mailhost

nginx\_mailhost: A list of mailhost vhost dict items.

```
config_nginx_mailhost:   true
nginx_mailhost:
  - vhost:               example.co.uk
    listen_port:         80
    listen_ip:           '*'
    ssl:                 true
    ssl_key:             /etc/ssl/private/ssl-cert-wildcard-example.co.uk.key
    ssl_cert:            /etc/ssl/certs/ssl-cert-wildcard-example.co.uk.pem
    ssl_port:            443
    starttls:            'on'
    protocol:            'smtp'
```

## Validate Nginx config 

It is good practice to validate Nginx configuration after a config change happens. Set nginx_configtest_enable to true to enable config validation.

```
nginx_configtest_enable: true
```
