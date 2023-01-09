WebSocket Applications
======================

Presentation
------------

WebSocket is a protocol defined in :rfc:`6455`.

It allows bi-directional communication on top of TCP. See diagram below.

|image0|

The communication starts with an HTTP request from the client, asking for a connection upgrade to websocket. This request contains a challenge (the key).

The server response contains the answer to this challenge.

Then, if everything is successful, the communication continues on top of TCP. The client and server can send requests from both side.


Protection by LemonLDAP::NG
---------------------------

You can protect your websocket application with the classic :doc:`LemonLDAP::NG handler<presentation>`.

The handler is set up as an HTTP/TCP reverse-proxy in front of the websocket application.

|image1|

You can configure the :doc:`access rules and headers<writingrulesand_headers>` as usual.

.. note::

    This scenario has been tested with Nginx.

- Only the initial HTTP handshake (request and response) is protected by LemonLDAP::NG. Later TCP traffic pass directly through Nginx reverse-proxy
- LemonLDAP::NG access rules are evaluated during the initial HTTP handshake (request and response) that upgrades the communication to websocket
- LemonLDAP::NG headers are sent during the initial HTTP handshake (request and response) that upgrades the communication to websocket

Be careful of the following scenario :

* an unprotected page with a button that connect to the websocket endpoint with ajax requests
* the websocket endpoint is protected by LemonLDAP
* user clicks the button, but the SSO session has expired at this moment

The unprotected page must manage the 302 return code sent by the SSO portal

 
Load-testing
------------

* when passing by the LemonLDAP Nginx handler, there is about ~30% overload for the initial HTTP websocket request and response
* when passing by the Nginx reverse-proxy, there is no significant overload of TCP websocket requests


.. |image0| image:: /websocket.png
   :class: align-center

.. |image1| image:: /websocket-sso.png
   :class: align-center

