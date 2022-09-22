Certificate reset
=================

Presentation
------------

This plugin allows users to reset their certificate informations.

**Kinematics**:

-  User click reset certificate button.
-  He enters his mail.
-  LL::NG looks for the user in users database with given information.
-  An email with a link is sent if user exists.
-  User clicks on the link and he is redirected to the portal.
-  The portal asks him to upload his certificate file (base64, pem
   only).
-  A confirmation mail is sent to confirm the certificate has been
   successfully reset.


.. danger::
      LDAP backend supported only



Configuration
-------------

**Requirements**

You have to activate the certificate reset link in the login page, go in
Manager, ``General Parameters`` → ``Portal`` → ``Customization`` →
``Buttons on login page``\ → ``Reset your Certificate``

The SMTP server must be setup, see :doc:`SMTP server setup<smtp>`.

The register module also must be setup. Go in Manager,
``General Parameters`` → ``Authentication parameters`` →
``Register Module`` and choose your module.

**Manager Configuration**

Go in Manager, ``General Parameters`` → ``Plugins`` →
``Certificate Reset Management``:

**Certificate reset mail content:**

* **Certificat reset mail subject**: Subject of mail sent when certificate is reset
* **Certificat reset mail content**: (optional): Content of mail sent when certificate is reset
* **Confirmation mail subject**: Subject of mail sent when certificate reset  is asked
* **Confirmation mail content**: (optional) Content of mail sent when certificate is asked


.. attention::

    By default, mail contents are empty in order to use
    templates:

    * portal/skins/common/mail_certificateConfirm.tpl
    * portal/skins/common/mail_certificateReset.tpl

    If you define custom mail contents in Manager, then templates won't be
    used.

**Other**

* **Reset Page URL**: URL of certificate reset page (default: [PORTAL]/certificateReset)
* **Certificate descrition attribute Name**:  Attribute where to save certificate description name (Default description)
* **Certificate hash attribute Name**:  Attribute where to store certificate hash (Default userCertificate;binary)
* **Minimun duration before expiration**: number of days of validity before certificate expires. Default 0.


.. danger::
   .p12 certificates only.



.. |image0| image:: /documentation/beta.png
   :width: 100px
