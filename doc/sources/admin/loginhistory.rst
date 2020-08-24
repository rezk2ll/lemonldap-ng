Login History
=============

Presentation
------------

LemonLDAP::NG allows one to store user logins and login attempts in
their persistent session.

Users can see their own history in menu, if menu module
``Login history`` is enabled.

Session history is always visible in session explorer for
administrators.

Configuration
-------------

This feature can be enabled and configured in Manager, in
``General Parameters`` » ``Plugins`` » ``Login History``.
You can define how many logins and failed logins will be stored.

A login is considered as successful if user get authenticated and is
granted a session; as failed, if he fails to authenticate or if he is
not allowed to open a session. In other cases which result on
impossibility to authenticate user, to retrieve data or to create a
session, nothing is stored.

By default, login time and IP address are stored in history, and the
error message prompted to the user for failed logins. It is possible to
store any additional session data. For example to store authentication
mode, you can set in ``Session data to store`` a new key ``_auth`` with
value ``Authentication mode``. The value will be used to display the
data.

To allow the Login History tab in Menu, configure it in
``General Parameters`` > ``Portal`` > ``Menu`` > ``Modules`` (see
:ref:`portal menu configuration<portalmenu-menu-modules>`).

You can also display a check box on the authentication form, to allow
user to see their login history before being redirected to the protected
application (see
:ref:`portal customization<portalcustom-other-parameters>`).
