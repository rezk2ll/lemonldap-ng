SMTP server setup
=================

Go in ``General Parameters`` > ``Advanced Parameters`` > ``SMTP``:


* **Session key containing mail address**: choose which session field contains mail address
* **SMTP Server**: IP or hostname of the SMTP server
* **SMTP Port**: Port of the SMTP server
* **SMTP User**: SMTP user if authentication is required
* **SMTP Password**: SMTP password if authentication is required
* **SSL/TLS protocol** and **SSL/TLS options**: Here you can enable SMTPS or startTLS


.. tip::



    -  If no SMTP server is configured, the mail will be sent via the local
       sendmail program. Else, Net::SMTP module is required to use the SMTP
       server
    -  The SMTP server value can hold the port, for example:
       ``mail.example.com:25``
    -  If authentication is configured, ``Authen::SASL`` and
       ``MIME::Base64`` modules are required



-  **Mail headers**:

   -  **Mail sender**: address seen in the "From" field (default:
      noreply@[DOMAIN])
   -  **Reply address**: address seen in the "Reply-To" field
   -  **charset**: Charset used for the body of the mail (default:
      utf-8)
