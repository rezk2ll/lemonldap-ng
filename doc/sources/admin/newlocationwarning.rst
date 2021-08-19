|image0|

New Location Warning Plugin
===========================

Presentation
------------

This plugin allows LL::NG to send a warning message to the user's email 
address when their account connects via a new IP address.

Following steps are performed:

#. User logs in from a new location
#. The IP address is compared to those in the connection history
#. If it's a new IP, a warning email is sent to the user's email address

Configuration
-------------



Just enable it in the Manager (section ``General Parameters`` > ``Advanced parameters`` > ``Security`` > ``New location warning``:

- **Activation**: Enable this plugin *(default: disabled)*
- **Session mail attribute**: Session key containing mail address *(default: mail)*
- **Warning mail subject**: Subject of the email containing the warning
- **Warning mail content**: Content of the email containing the warning

.. note::

   Following variables are available in:

   \* Warning email body => ``$newLocationIP``, ``$newLocationDate``, ``$newLocationUrl``

.. |image0| image:: /documentation/beta.png
   :width: 100px