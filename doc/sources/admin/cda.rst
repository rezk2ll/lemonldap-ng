Cross Domain Authentication
===========================

Presentation
------------

:ref:`cda`

Configuration
-------------

Go in Manager, ``General Parameters`` » ``Cookies`` »
``Multiple domains`` and set to ``On``.

To use this feature only locally, edit ``lemonldap-ng.ini`` in section
[all]:

.. code-block:: ini

   [all]
   cda = 1


.. attention::

    If your handler is being served by Nginx, you have to
    uncomment the following lines in your nginx configuration file:

    ::

       # If CDA is used, uncomment this
       auth_request_set $cookie_value $upstream_http_set_cookie;
       add_header Set-Cookie $cookie_value;



Handlers
~~~~~~~~

Choose "CDA" as type for each virtualHost concerned by CDA *(ie not in
main domain)*.

