Memcached session backend
=========================


.. important::

    \ `Memcached <http://memcached.org/>`__ can be used with
    LL::NG, but some features will not work since Memcached doesn't provide
    any parsing system:

    -  Session expiration: sessions will never expire (server side)
    -  :ref:`Session explorer<session-explorer>` will not work
    -  :ref:`Session restrictions<session-restrictions>` will not work

    To keep Memcached performance level and LL::NG features, you can replace
    `Memcached <http://memcached.org/>`__ by
    `Redis <http://code.google.com/p/redis/>`__ using
    :doc:`NoSQL session backend<nosqlsessionbackend>`.

Setup
-----

Install and launch a `Memcached server <http://memcached.org/>`__.

In the manager: set
`Apache::Session::Memcached <https://metacpan.org/pod/Apache::Session::Memcached>`__
in ``General parameters`` » ``Sessions`` » ``Session storage`` »
``Apache::Session module`` and add the following parameters (case
sensitive):

=================== ================= =============================
Required parameters
=================== ================= =============================
Name                Comment           Example
**Servers**         Memcached servers 10.0.0.1:20000 10.0.0.2:20000
=================== ================= =============================

See
`Apache::Session::Memcached <https://metacpan.org/pod/Apache::Session::Memcached>`__
for optional parameters.
