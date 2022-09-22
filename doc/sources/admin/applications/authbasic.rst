HTTP Basic Authentication
=========================

|image0|

Presentation
------------


.. attention::

    For now, this feature is only supported by Apache
    handler.

Extract from the `Wikipedia
article <http://en.wikipedia.org/wiki/Basic_access_authentication>`__:

In the context of an HTTP transaction, the basic access authentication
is a method designed to allow a web browser, or other client program, to
provide credentials – in the form of a user name and password – when
making a request.

Before transmission, the username and password are encoded as a sequence
of base-64 characters. For example, the user name Aladdin and password
open sesame would be combined as Aladdin:open sesame – which is
equivalent to QWxhZGRpbjpvcGVuIHNlc2FtZQ== when encoded in Base64.
Little effort is required to translate the encoded string back into the
user name and password, and many popular security tools will decode the
strings "on the fly".

So HTTP Basic Authentication is managed through an HTTP header
(``Authorization``), that can be forged by LL::NG, with this
precautions:

-  Data should not contains accents or special characters, as HTTP
   protocol only allow ASCII values in header (but depending on the HTTP
   server, you can use ISO encoded values)
-  You need to forward the password, which can be the user main password
   (if :doc:`password is stored in session<../passwordstore>`, or any
   user attribute (if you keep secondary passwords in users database).

Configuration
-------------

The Basic Authentication relies on a specific HTTP header, as described
above. So you have just to declare this header for the virtual host in
Manager.

For example, to forward login (``$uid``) and password (``$_password`` if
:doc:`password is stored in session<../passwordstore>`):

::

   Authorization => "Basic ".encode_base64("$uid:$_password", "")

LL::NG provides a special function named
:doc:`basic<../extendedfunctions>` to build this header.

So the above example can also be written like this:

::

   Authorization => basic($uid,$_password)


.. tip::

    The ``basic`` function will also force conversion from UTF-8
    to ISO-8859-1, which should be accepted by most of HTTP servers.

.. |image0| image:: /applications/http_logo.png
   :class: align-center

