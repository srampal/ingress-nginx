# Annotations

The following annotations are supported:

|Name                       | type |
|---------------------------|------|
|[ingress.kubernetes.io/add-base-url](#rewrite)|true or false|
|[ingress.kubernetes.io/app-root](#rewrite)|string|
|[ingress.kubernetes.io/affinity](#session-affinity)|cookie|
|[ingress.kubernetes.io/auth-realm](#authentication)|string|
|[ingress.kubernetes.io/auth-secret](#authentication)|string|
|[ingress.kubernetes.io/auth-type](#authentication)|basic or digest|
|[ingress.kubernetes.io/auth-tls-secret](#certificate-authentication)|string|
|[ingress.kubernetes.io/auth-tls-verify-depth](#certificate-authentication)|number|
|[ingress.kubernetes.io/auth-tls-verify-client](#certificate-authentication)|string|
|[ingress.kubernetes.io/auth-tls-error-page](#certificate-authentication)|string|
|[ingress.kubernetes.io/auth-url](#external-authentication)|string|
|[ingress.kubernetes.io/base-url-scheme](#rewrite)|string|
|[ingress.kubernetes.io/client-body-buffer-size](#client-body-buffer-size)|string|
|[ingress.kubernetes.io/configuration-snippet](#configuration-snippet)|string|
|[ingress.kubernetes.io/default-backend](#default-backend)|string|
|[ingress.kubernetes.io/enable-cors](#enable-cors)|true or false|
|[ingress.kubernetes.io/force-ssl-redirect](#server-side-https-enforcement-through-redirect)|true or false|
|[ingress.kubernetes.io/from-to-www-redirect](#redirect-from-to-www)|true or false|
|[ingress.kubernetes.io/limit-connections](#rate-limiting)|number|
|[ingress.kubernetes.io/limit-rps](#rate-limiting)|number|
|[ingress.kubernetes.io/proxy-body-size](#custom-max-body-size)|string|
|[ingress.kubernetes.io/proxy-connect-timeout](#custom-timeouts)|number|
|[ingress.kubernetes.io/proxy-send-timeout](#custom-timeouts)|number|
|[ingress.kubernetes.io/proxy-read-timeout](#custom-timeouts)|number|
|[ingress.kubernetes.io/proxy-next-upstream](#custom-timeouts)|string|
|[ingress.kubernetes.io/proxy-request-buffering](#custom-timeouts)|string|
|[ingress.kubernetes.io/rewrite-target](#rewrite)|URI|
|[ingress.kubernetes.io/secure-backends](#secure-backends)|true or false|
|[ingress.kubernetes.io/server-alias](#server-alias)|string|
|[ingress.kubernetes.io/server-snippet](#server-snippet)|string|
|[ingress.kubernetes.io/service-upstream](#service-upstream)|true or false|
|[ingress.kubernetes.io/session-cookie-name](#cookie-affinity)|string|
|[ingress.kubernetes.io/session-cookie-hash](#cookie-affinity)|string|
|[ingress.kubernetes.io/ssl-redirect](#server-side-https-enforcement-through-redirect)|true or false|
|[ingress.kubernetes.io/ssl-passthrough](#ssl-passthrough)|true or false|
|[ingress.kubernetes.io/upstream-max-fails](#custom-nginx-upstream-checks)|number|
|[ingress.kubernetes.io/upstream-fail-timeout](#custom-nginx-upstream-checks)|number|
|[ingress.kubernetes.io/upstream-hash-by](#custom-nginx-upstream-hashing)|string|
|[ingress.kubernetes.io/whitelist-source-range](#whitelist-source-range)|CIDR|

### Rewrite

In some scenarios the exposed URL in the backend service differs from the specified path in the Ingress rule. Without a rewrite any request will return 404.
Set the annotation `ingress.kubernetes.io/rewrite-target` to the path expected by the service.

If the application contains relative links it is possible to add an additional annotation `ingress.kubernetes.io/add-base-url` that will prepend a [`base` tag](https://developer.mozilla.org/en/docs/Web/HTML/Element/base) in the header of the returned HTML from the backend.

If the scheme of [`base` tag](https://developer.mozilla.org/en/docs/Web/HTML/Element/base) need to be specific, set the annotation `ingress.kubernetes.io/base-url-scheme` to the scheme such as `http` and `https`.

If the Application Root is exposed in a different path and needs to be redirected, set the annotation `ingress.kubernetes.io/app-root` to redirect requests for `/`.

Please check the [rewrite](../examples/rewrite/README.md) example.

### Session Affinity

The annotation `ingress.kubernetes.io/affinity` enables and sets the affinity type in all Upstreams of an Ingress. This way, a request will always be directed to the same upstream server.
The only affinity type available for NGINX is `cookie`.

Please check the [affinity](../examples/affinity/README.md) example.

### Authentication

Is possible to add authentication adding additional annotations in the Ingress rule. The source of the authentication is a secret that contains usernames and passwords inside the key `auth`.

The annotations are:
```
ingress.kubernetes.io/auth-type: [basic|digest]
```

Indicates the [HTTP Authentication Type: Basic or Digest Access Authentication](https://tools.ietf.org/html/rfc2617).

```
ingress.kubernetes.io/auth-secret: secretName
```

The name of the secret that contains the usernames and passwords with access to the `path`s defined in the Ingress Rule.
The secret must be created in the same namespace as the Ingress rule.

```
ingress.kubernetes.io/auth-realm: "realm string"
```

Please check the [auth](../examples/auth/basic/README.md) example.

### Custom NGINX upstream checks

NGINX exposes some flags in the [upstream configuration](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#upstream) that enable the configuration of each server in the upstream. The Ingress controller allows custom `max_fails` and `fail_timeout` parameters in a global context using `upstream-max-fails` and `upstream-fail-timeout` in the NGINX ConfigMap or in a particular Ingress rule. `upstream-max-fails` defaults to 0. This means NGINX will respect the container's `readinessProbe` if it is defined. If there is no probe and no values for `upstream-max-fails` NGINX will continue to send traffic to the container.

**With the default configuration NGINX will not health check your backends. Whenever the endpoints controller notices a readiness probe failure, that pod's IP will be removed from the list of endpoints. This will trigger the NGINX controller to also remove it from the upstreams.**

To use custom values in an Ingress rule define these annotations:

`ingress.kubernetes.io/upstream-max-fails`: number of unsuccessful attempts to communicate with the server that should occur in the duration set by the `upstream-fail-timeout` parameter to consider the server unavailable.

`ingress.kubernetes.io/upstream-fail-timeout`: time in seconds during which the specified number of unsuccessful attempts to communicate with the server should occur to consider the server unavailable. This is also the period of time the server will be considered unavailable.

In NGINX, backend server pools are called "[upstreams](http://nginx.org/en/docs/http/ngx_http_upstream_module.html)". Each upstream contains the endpoints for a service. An upstream is created for each service that has Ingress rules defined.

**Important:** All Ingress rules using the same service will use the same upstream. Only one of the Ingress rules should define annotations to configure the upstream servers.

Please check the [custom upstream check](../examples/customization/custom-upstream-check/README.md) example.

### Custom NGINX upstream hashing

NGINX supports load balancing by client-server mapping based on [consistent hashing](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#hash) for a given key. The key can contain text, variables or any combination thereof. This feature allows for request stickiness other than client IP or cookies. The [ketama](http://www.last.fm/user/RJ/journal/2007/04/10/392555/) consistent hashing method will be used which ensures only a few keys would be remapped to different servers on upstream group changes.

To enable consistent hashing for a backend:

`ingress.kubernetes.io/upstream-hash-by`: the nginx variable, text value or any combination thereof to use for consistent hashing. For example `ingress.kubernetes.io/upstream-hash-by: "$request_uri"` to consistently hash upstream requests by the current request URI.

### Certificate Authentication

It's possible to enable Certificate-Based Authentication (Mutual Authentication) using additional annotations in Ingress Rule.

The annotations are:
```
ingress.kubernetes.io/auth-tls-secret: secretName
```

The name of the secret that contains the full Certificate Authority chain `ca.crt` that is enabled to authenticate against this ingress. It's composed of namespace/secretName.

```
ingress.kubernetes.io/auth-tls-verify-depth
```

The validation depth between the provided client certificate and the Certification Authority chain.

```
ingress.kubernetes.io/auth-tls-verify-client
```

Enables verification of client certificates.

```
ingress.kubernetes.io/auth-tls-error-page
```

The URL/Page that user should be redirected in case of a Certificate Authentication Error

Please check the [tls-auth](../examples/auth/client-certs/README.md) example.

### Configuration snippet

Using this annotation you can add additional configuration to the NGINX location. For example:

```yaml
ingress.kubernetes.io/configuration-snippet: |
  more_set_headers "Request-Id: $request_id";
```

### Default Backend

The ingress controller requires a default backend. This service is handle the response when the service in the Ingress rule does not have endpoints.
This is a global configuration for the ingress controller. In some cases could be required to return a custom content or format. In this scenario we can use the annotation `ingress.kubernetes.io/default-backend: <svc name>` to specify a custom default backend.

### Enable CORS

To enable Cross-Origin Resource Sharing (CORS) in an Ingress rule add the annotation `ingress.kubernetes.io/enable-cors: "true"`. This will add a section in the server location enabling this functionality.
For more information please check https://enable-cors.org/server_nginx.html

### Server Alias

To add Server Aliases to an Ingress rule add the annotation `ingress.kubernetes.io/server-alias: "<alias>"`.
This will create a server with the same configuration, but a different server_name as the provided host.

*Note:* A server-alias name cannot conflict with the hostname of an existing server. If it does the server-alias
annotation will be ignored. If a server-alias is created and later a new server with the same hostname is created
the new server configuration will take place over the alias configuration.

For more information please see http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name

### Server snippet

Using the annotation `ingress.kubernetes.io/server-snippet` it is possible to add custom configuration in the server configuration block.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/server-snippet: |
set $agentflag 0;

if ($http_user_agent ~* "(Mobile)" ){
  set $agentflag 1;
}

if ( $agentflag = 1 ) {
  return 301 https://m.example.com;
}
```

**Important:** This annotation can be used only once per host

### Client Body Buffer Size

Sets buffer size for reading client request body per location. In case the request body is larger than the buffer,
the whole body or only its part is written to a temporary file. By default, buffer size is equal to two memory pages.
This is 8K on x86, other 32-bit platforms, and x86-64. It is usually 16K on other 64-bit platforms. This annotation is
applied to each location provided in the ingress rule.

*Note:* The annotation value must be given in a valid format otherwise the
For example to set the client-body-buffer-size the following can be done:

* `ingress.kubernetes.io/client-body-buffer-size: "1000"` # 1000 bytes
* `ingress.kubernetes.io/client-body-buffer-size: 1k` # 1 kilobyte
* `ingress.kubernetes.io/client-body-buffer-size: 1K` # 1 kilobyte
* `ingress.kubernetes.io/client-body-buffer-size: 1m` # 1 megabyte
* `ingress.kubernetes.io/client-body-buffer-size: 1M` # 1 megabyte

For more information please see http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size

### External Authentication

To use an existing service that provides authentication the Ingress rule can be annotated with `ingress.kubernetes.io/auth-url` to indicate the URL where the HTTP request should be sent.
Additionally it is possible to set `ingress.kubernetes.io/auth-method` to specify the HTTP method to use (GET or POST).

```yaml
ingress.kubernetes.io/auth-url: "URL to the authentication service"
```

Please check the [external-auth](../examples/auth/external-auth/README.md) example.

### Rate limiting

The annotations `ingress.kubernetes.io/limit-connections`, `ingress.kubernetes.io/limit-rps`, and `ingress.kubernetes.io/limit-rpm` define a limit on the connections that can be opened by a single client IP address. This can be used to mitigate [DDoS Attacks](https://www.nginx.com/blog/mitigating-ddos-attacks-with-nginx-and-nginx-plus).

`ingress.kubernetes.io/limit-connections`: number of concurrent connections allowed from a single IP address.

`ingress.kubernetes.io/limit-rps`: number of connections that may be accepted from a given IP each second.

`ingress.kubernetes.io/limit-rpm`: number of connections that may be accepted from a given IP each minute.

You can specify the client IP source ranges to be excluded from rate-limiting through the `ingress.kubernetes.io/limit-whitelist` annotation. The value is a comma separated list of CIDRs.

If you specify multiple annotations in a single Ingress rule, `limit-rpm`, and then `limit-rps` takes precedence.

The annotation `ingress.kubernetes.io/limit-rate`, `ingress.kubernetes.io/limit-rate-after` define a limit the rate of response transmission to a client. The rate is specified in bytes per second. The zero value disables rate limiting. The limit is set per a request, and so if a client simultaneously opens two connections, the overall rate will be twice as much as the specified limit.

`ingress.kubernetes.io/limit-rate-after`: sets the initial amount after which the further transmission of a response to a client will be rate limited.

`ingress.kubernetes.io/limit-rate`: rate of request that accepted from a client each second.

To configure this setting globally for all Ingress rules, the `limit-rate-after` and `limit-rate` value may be set in the NGINX ConfigMap. if you set the value in ingress annotation will cover global setting.

### SSL Passthrough

The annotation `ingress.kubernetes.io/ssl-passthrough` allows to configure TLS termination in the pod and not in NGINX.

**Important:**

- Using the annotation `ingress.kubernetes.io/ssl-passthrough` invalidates all the other available annotations. This is because SSL Passthrough works in L4 (TCP).
- The use of this annotation requires the flag `--enable-ssl-passthrough` (By default it is disabled)

### Secure backends

By default NGINX uses `http` to reach the services. Adding the annotation `ingress.kubernetes.io/secure-backends: "true"` in the Ingress rule changes the protocol to `https`.

### Service Upstream

By default the NGINX ingress controller uses a list of all endpoints (Pod IP/port) in the NGINX upstream configuration. This annotation disables that behavior and instead uses a single upstream in NGINX, the service's Cluster IP and port. This can be desirable for things like zero-downtime deployments as it reduces the need to reload NGINX configuration when Pods come up and down. See issue [#257](https://github.com/kubernetes/ingress/issues/257).

#### Known Issues

If the `service-upstream` annotation is specified the following things should be taken into consideration:

* Sticky Sessions will not work as only round-robin load balancing is supported.
* The `proxy_next_upstream` directive will not have any effect meaning on error the request will not be dispatched to another upstream.

### Server-side HTTPS enforcement through redirect

By default the controller redirects (301) to `HTTPS` if TLS is enabled for that ingress. If you want to disable that behavior globally, you can use `ssl-redirect: "false"` in the NGINX config map.

To configure this feature for specific ingress resources, you can use the `ingress.kubernetes.io/ssl-redirect: "false"` annotation in the particular resource.

When using SSL offloading outside of cluster (e.g. AWS ELB) it may be useful to enforce a redirect to `HTTPS` even when there is not TLS cert available. This can be achieved by using the `ingress.kubernetes.io/force-ssl-redirect: "true"` annotation in the particular resource.

### Redirect from to www

In some scenarios is required to redirect from `www.domain.com` to `domain.com` or viceversa.
To enable this feature use the annotation `ingress.kubernetes.io/from-to-www-redirect: "true"`

**Important:**
If at some point a new Ingress is created with a host equal to one of the options (like `domain.com`) the annotation will be omitted.

### Whitelist source range

You can specify the allowed client IP source ranges through the `ingress.kubernetes.io/whitelist-source-range` annotation. The value is a comma separated list of [CIDRs](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing), e.g.  `10.0.0.0/24,172.10.0.1`.

To configure this setting globally for all Ingress rules, the `whitelist-source-range` value may be set in the NGINX ConfigMap.

*Note:* Adding an annotation to an Ingress rule overrides any global restriction.

### Cookie affinity

If you use the ``cookie`` type you can also specify the name of the cookie that will be used to route the requests with the annotation `ingress.kubernetes.io/session-cookie-name`. The default is to create a cookie named 'route'.

In case of NGINX the annotation `ingress.kubernetes.io/session-cookie-hash` defines which algorithm will be used to 'hash' the used upstream. Default value is `md5` and possible values are `md5`, `sha1` and `index`.
The `index` option is not hashed, an in-memory index is used instead, it's quicker and the overhead is shorter Warning: the matching against upstream servers list is inconsistent. So, at reload, if upstreams servers has changed, index values are not guaranteed to correspond to the same server as before! USE IT WITH CAUTION and only if you need to!

In NGINX this feature is implemented by the third party module [nginx-sticky-module-ng](https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng). The workflow used to define which upstream server will be used is explained [here](https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/raw/08a395c66e425540982c00482f55034e1fee67b6/docs/sticky.pdf)

### Custom timeouts

Using the configuration configmap it is possible to set the default global timeout for connections to the upstream servers.
In some scenarios is required to have different values. To allow this we provide annotations that allows this customization:

- `ingress.kubernetes.io/proxy-connect-timeout`
- `ingress.kubernetes.io/proxy-send-timeout`
- `ingress.kubernetes.io/proxy-read-timeout`
- `ingress.kubernetes.io/proxy-next-upstream`
- `ingress.kubernetes.io/proxy-request-buffering`

### Custom max body size

For NGINX, 413 error will be returned to the client when the size in a request exceeds the maximum allowed size of the client request body. This size can be configured by the parameter [`client_max_body_size`](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size).

To configure this setting globally for all Ingress rules, the `proxy-body-size` value may be set in the NGINX ConfigMap.
To use custom values in an Ingress rule define these annotation:

```yaml
ingress.kubernetes.io/proxy-body-size: 8m
```
