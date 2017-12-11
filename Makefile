install:
	python buildout/bootstrap.py
	bin/buildout

nginx-info:
	./parts/openresty/nginx/sbin/nginx -V

nginx-configtest:
	./parts/openresty/nginx/sbin/nginx -c `pwd`/nginx.conf -t

nginx-run:
	./parts/openresty/nginx/sbin/nginx -c `pwd`/nginx.conf -g "daemon off;"
