|image0|

New Location Warning Plugin
===========================

Presentation
------------

This plugin allows LL::NG to send a warning message to the user's email
address when their account connects from a new location.

By default, the location is the IP address. Meaning that any connection from a
different IP address will send a warning. If this is not what you want, you can
change the way location is computed (see below).

Following steps are performed when the user logs in

#. Extract the location from session info (by default, the IP address is used)
#. Compare the current location to the previous locations saved in history
#. If it is a new location, send an email to warn the user
#. On the next login, the location will no longer be considered as new

The very first time a user logs in (empty login history), no email is sent.

Configuration
-------------

Just enable it in the Manager (section ``General Parameters`` > ``Advanced parameters`` > ``Security`` > ``New location warning``:

- **Activation**: Enable this plugin *(default: disabled)*
- **Session attribute containing location**: Indicate the session attribute you are using to store the location. You can use `ipAddr`, or a custom macro.
- **Session attribute to display**: By default, the raw value of the location session attribute is displayed in the warning email. If you want to use a different session attribute in the warning email, you can specify it here.
- **Maximum number of locations to consider**: By default, all previous value of the location are checked
- **Session mail attribute**: Session key containing mail address *(default: mail)*
- **Warning mail subject**: Subject of the email containing the warning
- **Warning mail content**: Content of the email containing the warning

.. warning::
    If you use a macro instead of ``ipAddr`` as the location value, be sure to add the name of this macro to

    General Parameters » Plugins » Login History » Session data to store

    Otherwise, the value of the macro will not be remembered across logins

Email body variables
~~~~~~~~~~~~~~~~~~~~

Following variables are available in the Warning email body:

* ``$location``: the location value, from **Session attribute to display**
* ``$date``: the date of login
* ``$ua``: the full user agent string

.. |image0| image:: /documentation/beta.png
   :width: 100px
