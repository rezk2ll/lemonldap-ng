SMTP server setup
=================

Go in ``General Parameters`` > ``Advanced Parameters`` > ``SMTP``:


* **Session key containing mail address**: choose which session field contains
  mail address
* **SMTP Server**: IP or hostname of the SMTP server
* **SMTP Port**: Port of the SMTP server
* **SMTP User**: SMTP user if authentication is required
* **SMTP Password**: SMTP password if authentication is required
* **SSL/TLS protocol** and **SSL/TLS options**: Here you can enable SMTPS or
  startTLS. A list of possible options can be found in the `IO::Socket::SSL
  documentation <https://metacpan.org/pod/IO::Socket::SSL>`__.


.. tip::

    -  If no SMTP server is configured, the mail will be sent via the local
       sendmail program. Else, Net::SMTP module is required to use the SMTP
       server
    -  The SMTP server value can hold the port, for example:
       ``mail.example.com:25``

.. warning::

   - Older versions of the Email::Sender library have limitations when it comes
     to SMTPS or STARTTLS support. Versions lower than 1.300027 will not be
     able to check the remote server certificate or use custom IO::Socket::SSL
     options.

-  **Mail headers**:

   -  **Mail sender**: address seen in the "From" field (default:
      noreply@[DOMAIN])
   -  **Reply address**: address seen in the "Reply-To" field
   -  **charset**: Charset used for the body of the mail (default:
      utf-8)

Testing your email setup
------------------------

.. versionadded:: 2.0.10

You can test your email setup in the ``General Parameters`` > ``Advanced
Parameters`` > ``SMTP`` page by using the ``Send test email`` button in the
manager.

.. tip::

   You need to save your SMTP configuration before you can test it

.. versionadded:: 2.0.10

You can also test your email setup using the ``test-email`` command in the CLI ::

   lemonldap-ng-cli test-email dwho@badwolf.org
