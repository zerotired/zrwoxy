#############################
zrwoxy, a trolling HTTP proxy
#############################


************
Introduction
************
Always wanted to manipulate HTTP and HTML using Nginx and Lua?
Who didn't!?

This is a proof of concept targeting the unaware HTTP user
by manipulating unencrypted HTTP traffic passing through
a HTTP proxy.

The nice thing is that it actually gets down to the HTML level,
so you can do funny things like injecting CSS and other kinds of
DOM manipulation.


****
How?
****
It uses Nginx and its embedded LuaJIT scripting engine
as well as two nice Lua modules for processing HTTP and HTML.

- HTTP library: https://github.com/pintsized/lua-resty-http
- HTML library: https://github.com/craigbarnes/lua-gumbo


****
MITM
****
In order to make this work as a `transparent http proxy <https://en.wikipedia.org/wiki/Proxy_server#Transparent_proxy>`_::

    iptables -t nat -D PREROUTING -s 192.168.0.0/24 -p tcp --dport 80 -j DNAT --to-destination zrwoxy.local:8080


Alternative:
https://en.wikipedia.org/wiki/Web_Proxy_Auto-Discovery_Protocol


**********
References
**********
We recommend using `OpenResty <https://openresty.org/>`_.

An earlier implementation of this uses the nice "replace-filter-nginx-module",
you can find respective configuration directives in ``nginx.conf``.
See also https://github.com/openresty/replace-filter-nginx-module.


*****
Setup
*****
TODO.
