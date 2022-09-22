Synapse Matrix home server
==========================

|image0|

Presentation
------------

Synapse is the reference implementation of a Matrix home server, written in Python.

Configuring Synapse
-------------------

See `The official Synapse documentation <https://matrix-org.github.io/synapse/latest/openid.html>`__ for details


.. code:: yaml

    oidc_providers:
      - idp_id: lemonldap
        idp_name: lemonldap
        discover: true
        issuer: "https://auth.example.com/" # TO BE FILLED: replace with your domain
        client_id: "your client id" # TO BE FILLED
        client_secret: "your client secret" # TO BE FILLED
        scopes:
          - "openid"
          - "profile"
          - "email"
        user_mapping_provider:
          config:
            localpart_template: "{{ user.preferred_username }}}"
            # TO BE FILLED: If your users have names in LemonLDAP::NG and you want those in Synapse, this should be replaced with user.name|capitalize or any valid filter.
            display_name_template: "{{ user.preferred_username|capitalize }}"


Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

Add a :doc:`new OpenID Connect relaying party<..//idpopenidconnect>`
with the following parameters:

* **Options/Basic**
    * **Client ID**: same as ``client_id`` configuration in Synapse
    * **Client Secret**: same as ``client_secret`` configuration in Synapse
    * **Allowed redirection addresses**: ``[synapse public baseurl]/_synapse/client/oidc/callback``
* **Options/Security**
   * **ID Token signature algorithm**:: ``RS256``
* **Exported Attributes**
   * ``preferred_username``: ``uid``

(adjust if you don't store your username attribute in the ``uid`` session variable

.. |image0| image:: /applications/matrix_logo.png
   :class: align-center

