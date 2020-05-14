Refresh session plugin (API)
============================

This plugin adds an endpoint to refresh sessions by user. It adds a
``https://portal/refreshsession`` endpoint. Protect it by webserver
configuration.

This plugin is available with LLNG ≥ 2.0.7.

Usage
-----

This endpoint accepts only POST requests with a JSON content:

==================== ============================
Request              Response
==================== ============================
``{"uid":"userid"}`` ``{"updated":1,"errors":0}``
==================== ============================
