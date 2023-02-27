Browseable session backend
==========================

Presentation
------------

Browseable session backend
(`Apache::Session::Browseable <https://metacpan.org/pod/Apache::Session::Browseable>`__)
works exactly like Apache::Session::\* corresponding module but add
index that increase the speed of some operations. It is recommended in production deployments.

.. note::

    Without index, LL::NG will have to retrieve all sessions stored in
    backend and deserialize then filter each of them.

The following table list fields to index for each session type:


.. _fieldstoindex:

List of fields to index by session type
---------------------------------------

.. list-table::
   :header-rows: 1

   * - Session Type
     - Fields to index
   * - Sessions (global) [1]_
     - \_whatToTrace \_session_kind \_utime ipAddr \_httpSessionType user mail \_session_uid
   * - Persistent sessions
     - \_session\_kind \_httpSessionType \_session\_uid ipAddr \_whatToTrace
   * - CAS sessions
     - \_session_kind \_utime \_cas\_id pgtIou
   * - SAML sessions
     - \_session_kind \_utime \_saml_id ProxyID \_nameID \_assert_id \_art_id
   * - OIDC sessions
     - \_session_kind \_utime

.. [1]
   - ``user`` is used by :doc:`resetpassword`.
   - ``mail`` is used by :doc:`register`.
   - ``_session_uid`` is used by :doc:`stayconnected`.

.. note::

   If you have configured LemonLDAP::NG to use something other than
   `_whatToTrace` as the main session identifier, you must replace
   `_whatToTrace` with the new session field in the previous list

See Apache::Session::Browseable man page to see how use indexes.

.. tip::

    It is advised to use separate session backends for standard sessions, SAML
    sessions and CAS sessions, in order to avoid unused indexes.

Available backends
------------------

.. toctree::
   :maxdepth: 1

   PgJSON Backend (recommended) <pgjsonsessionbackend>
   browseablemysqlsessionbackend
   browseableldapsessionbackend
   redissessionbackend
