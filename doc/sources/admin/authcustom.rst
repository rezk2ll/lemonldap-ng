Custom authentication modules
=============================

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

This artifact allows one to define its own modules (authentication, user
database, password or register database).


.. tip::

    The developer documentation is available in Portal manpages.
    See Auth.pod and UserDB.pod

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose 'Custom module'.

Then, you just have to define class names of your custom modules in
"Custom module names". Custom parameters can be set in "Additional
parameters". Full path must be specify.

You can define your own customAuth module icon. Icon must be in
site/htdocs/static/common/modules/icon.png


.. tip::

    ::Auth::My::Dev.pm means Lemonldap::NG::Portal::Auth::My::Dev



.. attention::

    Be careful. Don' t use an already attributed name in
    configuration.

These parameters are available in your plugins using
``$self->conf->{customAddParams}->{<customName>}``.

Read portal manpages to see how to write these plugins.
