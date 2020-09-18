## Check cookie existence

```
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/health_check
RewriteCond %{HTTP_COOKIE} !\bHEADER_NAME=VALUE\b
RewriteRule ^ - [F]
```

## Check header value
```
RewriteCond %{HTTP:HEADER_NAME} !^(VALUE1|VALUE2|VALUE3)$
RewriteCond %{REQUEST_URI} !^/health_check
RewriteRule ^ - [F]
```

Reference:
[1] https://webmasters.stackexchange.com/questions/97071/using-mod-rewrite-to-check-for-existence-of-a-cookie
[2] https://stackoverflow.com/questions/29305224/check-for-specific-header-value-in-rewritecond
