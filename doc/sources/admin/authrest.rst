REST
====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

This backend can be used to delegate authentication to some webservices.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose REST for authentication, users and/or password modules.

Then, go in ``REST parameters`` and you just have to set REST URL to
provide wanted services:

===================== ====================================
Module                Parameter
===================== ====================================
Authentication level  Authentication level for this module
Authentication        Authentication URL
User database         User data URL
Password confirmation Password confirmation URL
Password change       Password change URL
===================== ====================================


.. tip::

    You can then choose any other module for users and
    password.

REST Dialog
-----------

LemonLDAP::NG will call the endpoints you declared at various steps
during the login process.

The request performed by LemonLDAP::NG is a POST on the URL you
specified, the content of the POST is a JSON document
(``Content-Type: application/json``).

REST web services must respond with a success HTTP code (200), and the
response must be a JSON document containing a ``result`` key.
Auth/UserDB endpoints can add an ``info`` array that will be stored in
session data (without reading "Exported variables").

========================= ======================================= ===================================================
URL                       Query                                   Response
========================= ======================================= ===================================================
Authentication URL        ``{"user":$user,"password":$password}`` ``{"result":true/false,"info":{...}}``
User data URL             ``{"user":$user}``                      ``{"result":true/false,"info":{"uid":"dwho",...}}``
Password confirmation URL ``{"user":$user,"password":$password}`` ``{"result":true/false}``
Password change URL       ``{"user":$user,"password":$password}`` ``{"result":true/false}``
========================= ======================================= ===================================================


.. tip::

    To have only one REST call during the login process, you can
    set REST only as an Authentication backend, configure Null as your User
    Database, and make sure the REST authentication URL send all your user
    attributes in the ``info`` response key


.. _rest-args:

Additional arguments
--------------------

.. versionadded:: 2.23.0

You can define additional arguments that will be sent along ``user``, ``password``, etc. in the body of the REST request.

In the *arguments* section, specify the name of the JSON parameter as the *key* and a perl expression as the  *value*.

However keep in mind that in most situations, user attributes will not be available yet. But you can still use CGI environment variables.

For example, setting a key of ``ip`` and a value of ``$ENV{REMOTE_ADDR}`` will result in the following REST authentication request:

.. code:: json

    {
      "ip": "127.0.0.1",
      "password": "dwho",
      "user": "dwho"
    }
