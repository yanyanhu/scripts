## Check cookie existence

RewriteEngine On
RewriteCond %{HTTP_COOKIE} !\bAUTHORIZED_RELAY=$KEY
RewriteRule ^ - [F]

Reference:
[1] https://webmasters.stackexchange.com/questions/97071/using-mod-rewrite-to-check-for-existence-of-a-cookie
