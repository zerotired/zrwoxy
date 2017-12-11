#############################
zrwoxy, a trolling HTTP proxy
#############################


************
Introduction
************
Always wanted to manipulate HTTP and HTML using Nginx and Lua?
Who didn't!?

This is a proof of concept targeting the unaware HTTP user by manipulating
unencrypted HTTP traffic passing through a HTTP proxy.

The nice thing is that it actually gets down to the HTML level, so you can do
funny things like injecting CSS and other kinds of DOM manipulation confidently
without having to fight with regular expressions.


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
In order to make this work as a `transparent http proxy <https://en.wikipedia.org/wiki/Proxy_server#Transparent_proxy>`_ using a Linux firewall rule::

    iptables -t nat -D PREROUTING -s 192.168.0.0/24 -p tcp --dport 80 -j DNAT --to-destination zrwoxy.local:8080

Alternatively, you can have a look at the `Web Proxy Auto-Discovery Protocol (WPAD) <https://en.wikipedia.org/wiki/Web_Proxy_Auto-Discovery_Protocol>`_ for disseminating proxy information.


*****
Setup
*****

Install
=======
::

    make install

Run
===
::

    # Display version and configuration options
    make nginx-info

    # Test configuration
    make nginx-configtest

    # Run daemon in foreground
    make nginx-run

Test
====
Fire a HTTP request using `HTTPie <https://httpie.org/>`_::

    http --follow --proxy http:http://localhost:8080 http://www.ilo.de/


********
Appendix
********

Notes
=====
We recommend using `OpenResty <https://openresty.org/>`_.

An earlier implementation of this uses the nice
`replace-filter-nginx-module <https://github.com/openresty/replace-filter-nginx-module>`_,
you can find respective ``replace_filter`` configuration directives in ``nginx.conf``.

References
==========
- https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/
