Risk-based Authentication
=========================

Our definition
--------------

Risk-based authentication is the ability to take into account the context of
the authentication process, and react accordingly, by increasing the
authentication challenge (second factor, email confirmation) or trigger out of
band actions (email notifications, alerts..).

.. warning::

   All the features presented on this page are not natively supported by
   LemonLDAP::NG but can be added through custom plugins or configuration

The authentication context can include:

* Source IP address
* Access time
* Previous authentications (history)
* Using the same browser as previous logins

Reactions can include:

* Triggering or skipping the second factor
* Sending an email to warn the user of a suspicious login
* Denying attempt if the suspicion level is too high

Implementation in LemonLDAP::NG
-------------------------------

LemonLDAP::NG uses the ``_riskLevel`` and ``_riskDetails`` session variables to
keep track of the risk associated to the current authentication.

Detection plugins will raise or lower the risk level, and store fine-grained
details in the risk details object.

Action plugins may use the risk level to trigger certain actions, and can
translate the risk detail items into user-friendly messages.


Compatible plugins
------------------

Detection
~~~~~~~~~

New location warning
^^^^^^^^^^^^^^^^^^^^

.. versionadded:: 2.0.14

The :doc:`New Location warning <newlocationwarning>` plugin will increase the risk level by 1 when triggered, and will store the **Session attribute to display** in ``$_riskDetail->{newLocation}``.

Action
~~~~~~

Forbidding/triggering second factors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can use the following activation rule to trigger second factors if the risk level is high::

    $_riskLevel > 0

Or, if you use self registration::

    has2f('TOTP') and $_riskLevel > 0

Denying login
^^^^^^^^^^^^^

You can use :doc:`session opening conditions <grantsession>` to deny access if the risk level is too high with a rule like this ::

    $_riskLevel < 2

This will forbid sessions from being opened if the risk level is greater or equal to 2
