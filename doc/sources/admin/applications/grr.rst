GRR
===

|image0|

Presentation
------------

`GRR <http://grr.devome.com/fr/>`__ is a room booking software.

HTTP header
-----------

Configuration
~~~~~~~~~~~~~

GRR has a SSO configuration page in its administration panel.

Do not use Lemonldap mode, which is for a very old Lemonldap version,
but HTTP authentication.

Set the default profile of connected users and which headers contains
surname, firstname and mail.

|image1|

GRR will check the username in REMOTE_USER, so use
:doc:`remote header conversion<../header_remote_user_conversion>` if you
are in proxy mode.

GRR virtual host in LL::NG
~~~~~~~~~~~~~~~~~~~~~~~~~~

Access rules:

-  ^/index.php => accept
-  default => unprotect

Headers:

-  Auth-User $uid
-  Auth-Sn: $sn
-  Auth-GivenName: $givenName
-  Auth-Mail: $mail

.. |image0| image:: /applications/grr_logo.png
   :class: align-center
.. |image1| image:: /applications/screenshot_grr_configuration.png
   :class: align-center

