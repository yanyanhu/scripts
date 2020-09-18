## Check cookie existence

```
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/health_check
RewriteCond %{HTTP_COOKIE} !\bAUTHORIZED_RELAY=$KEY\b
RewriteRule ^ - [F]
```

Reference:
[1] https://webmasters.stackexchange.com/questions/97071/using-mod-rewrite-to-check-for-existence-of-a-cookie
