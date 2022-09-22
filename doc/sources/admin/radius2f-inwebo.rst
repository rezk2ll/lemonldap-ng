InWebo Second Factor
====================

`InWebo <https://www.inwebo.com/>`_ is a proprietary MFA solution.
You can use is as second factor through :doc:`Radius 2FA module<radius2f>`.

Configuration
~~~~~~~~~~~~~

On InWebo side :

- Create a connector of type ``Radius Push``.
- Fill in the “IP Address” field with the IP of the public interface of your LL::NG server.
- Enter a secret, that you will also configure on LL::NG side.

See `InWebo Radius documentation <https://inwebo.atlassian.net/wiki/spaces/DOCS/pages/2216886275/RADIUS+integration+and+redundancy>`_ for more details.

On LL::NG side, go in "General Parameters » Second factors »
Radius second factor".

-  **Activation**: Set to ``On`` to activate this module, or use a
   specific rule to select which users may use this type of second
   factor
-  **Server hostname**: The hostname of InWebo Radius server (for example `radius2.myinwebo.com`)
-  **Shared secret**: The secret key declared on InWebo side

See :doc:`Radius 2FA module<radius2f>` for more details.
