Bootstrap portal skin
=====================

The default portal skin, named ``bootstrap``, is built on Bootstrap 5.3,
Font Awesome 6 (Free) and a modernized SCSS-driven theme. It replaces the
former Bootstrap 4 implementation of the ``bootstrap`` skin.

.. note::

   This is an in-place upgrade of the ``bootstrap`` skin: the skin name is
   unchanged, so existing configurations (``portalSkin = bootstrap``) keep
   working with no change. However, if you maintain a **custom skin derived
   from the old Bootstrap 4** ``bootstrap`` **skin**, you will need to port it
   to Bootstrap 5 — see `Migrating a custom skin to Bootstrap 5`_ below.

This page describes what the skin ships with, how to customize it, and how
to migrate a custom skin from the former Bootstrap 4 version.

Activation
----------

The ``bootstrap`` skin is the default; nothing needs to be done to enable
it. It can be (re)selected in the Manager under ``General Parameters`` >
``Portal`` > ``Customization`` > ``Default skin`` (choose ``Bootstrap``).

Per-URL or per-user skin selection (via ``portalSkinRules``) works as
usual.

What ships with the skin
------------------------

* Bootstrap 5.3 (CSS + JS bundle, Popper included)
* Font Awesome 6 Free (CSS, webfonts, ``v4-shims`` for backwards-compatible
  ``fa fa-foo`` syntax)
* A small SCSS layer with brand tokens and component overrides
* The portal templates (``site/templates/bootstrap/``) using
  Bootstrap 5 conventions
* jQuery is still loaded (the portal's own JavaScript still uses it). The
  Bootstrap framework itself is jQuery-free; future iterations will reduce
  jQuery usage in the portal scripts.

Dark mode
~~~~~~~~~

The skin currently ships **light mode only**. Bootstrap 5.3's color-mode
infrastructure is in place (the SCSS includes a ``_dark.scss`` partial
ready for tokens), but no dark stylesheet or UX toggle is provided yet.
Dark mode is planned for a future iteration.

Customization
-------------

Configuration parameters (skin background, custom CSS, custom JS, login
options, etc.) work identically to the ``bootstrap`` skin — see
:doc:`portalcustom` for the full list.

Custom CSS overrides (``portalCustomCss``)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Drop a CSS file under ``/usr/share/lemonldap-ng/portal/htdocs/static/`` and
reference it via ``portalCustomCss``. It is loaded after the skin's
compiled stylesheet, so any selector you add wins.

SCSS overrides (advanced)
~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to retune the brand palette or component tokens, you can build
your own ``styles.css`` from the SCSS sources shipped with the project.

Sources are in ``lemonldap-ng-portal/site/scss-src/``:

::

   _tokens.scss        # design tokens (palette, radius, fonts) — pre-Bootstrap
   _components.scss    # component overrides — post-Bootstrap
   _dark.scss          # dark-mode placeholder (currently empty)
   bootstrap.scss      # entry point (imports Bootstrap 5 via the npm alias)

The build target is::

   make scss

It uses ``sassc`` (Debian package: ``sassc``) when available, and falls
back to ``node-sass`` otherwise. Output is written to
``site/htdocs/static/bootstrap/css/styles.css`` and ``styles.min.css``.

To build a deployment-time variant, copy the SCSS sources into your own
project, override the tokens you want and re-run the equivalent compile
command pointing the include path to the npm-installed Bootstrap.


Migrating a custom skin to Bootstrap 5
--------------------------------------

If you maintain a custom skin derived from the former Bootstrap 4
``bootstrap`` skin and want to switch it to Bootstrap 5, the work is mostly
mechanical class renames
plus a few component restructurings. The portal's own port is a good
reference; the table below summarizes the most common changes you will
need to apply to your ``.tpl`` files and to any custom ``.css`` you ship.

Class renames (BS 4 → BS 5)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 42 58

   * - Bootstrap 4
     - Bootstrap 5
   * - ``data-toggle``
     - ``data-bs-toggle``
   * - ``data-target``
     - ``data-bs-target``
   * - ``data-dismiss``
     - ``data-bs-dismiss``
   * - ``data-ride``
     - ``data-bs-ride``
   * - ``data-slide``
     - ``data-bs-slide``
   * - ``data-spy``
     - ``data-bs-spy``
   * - ``data-parent``
     - ``data-bs-parent``
   * - ``data-backdrop``
     - ``data-bs-backdrop``
   * - ``data-keyboard``
     - ``data-bs-keyboard``
   * - ``pull-left`` / ``pull-right``
     - ``float-start`` / ``float-end``
   * - ``float-left`` / ``float-right``
     - ``float-start`` / ``float-end``
   * - ``text-left`` / ``text-right``
     - ``text-start`` / ``text-end``
   * - ``ml-*`` / ``mr-*``
     - ``ms-*`` / ``me-*``
   * - ``pl-*`` / ``pr-*``
     - ``ps-*`` / ``pe-*``
   * - ``font-weight-bold``
     - ``fw-bold``
   * - ``font-weight-normal``
     - ``fw-normal``
   * - ``font-weight-light``
     - ``fw-light``
   * - ``font-italic``
     - ``fst-italic``
   * - ``sr-only``
     - ``visually-hidden``
   * - ``form-group``
     - ``mb-3`` (or other margin utility)
   * - ``form-row``
     - ``row g-2`` (or similar)
   * - ``custom-control custom-checkbox``
     - ``form-check``
   * - ``custom-control-input``
     - ``form-check-input``
   * - ``custom-control-label``
     - ``form-check-label``
   * - ``custom-select``
     - ``form-select``
   * - ``custom-range``
     - ``form-range``
   * - ``badge-primary`` (etc.)
     - ``badge bg-primary`` (etc.)
   * - ``btn-block``
     - ``d-grid`` wrapper, or ``w-100``
   * - ``close``
     - ``btn-close`` (drop the inner ``×`` span)

Component restructurings
~~~~~~~~~~~~~~~~~~~~~~~~

* **Input groups** — drop the ``input-group-prepend`` / ``input-group-append``
  wrapper ``<div>``. Bootstrap 5 places ``<input>`` and addons as direct
  siblings inside ``.input-group``.

* **Modals close button** — Bootstrap 5 expects::

      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>

  with no inner ``<span>&times;</span>``. The X is rendered via CSS.

* **Navbar light/dark variants** — ``navbar-light`` / ``navbar-dark`` still
  work but are deprecated in 5.3. Prefer ``data-bs-theme="light|dark"`` on
  the ``<nav>`` element if you want explicit color modes.

* **Forms layout** — most ``.form-group`` blocks become ``.mb-3``. Some
  layouts may want ``.row.g-3`` or input-group structures instead. Adjust
  case by case.

Font Awesome 4 → 6
~~~~~~~~~~~~~~~~~~

The skin loads Font Awesome 6 Free **plus** the official ``v4-shims``
stylesheet, which keeps existing ``<i class="fa fa-X">`` markup working
through the rename map maintained upstream by Font Awesome. You only need
to rewrite icon classes if you want to drop the v4-shims layer or to use
icon variants only available in FA 6 (``fa-solid``, ``fa-regular``,
``fa-brands``).

To explicitly target FA 6:

::

   <i class="fa-solid fa-user"></i>
   <i class="fa-regular fa-circle-check"></i>
   <i class="fa-brands fa-github"></i>

JavaScript notes
~~~~~~~~~~~~~~~~

* Bootstrap 5 events are still emitted on jQuery objects (e.g.
  ``$('#m').on('show.bs.modal', ...)`` continues to work) but Bootstrap
  itself no longer requires jQuery.
* If you initialize Bootstrap components programmatically, the API is
  ``bootstrap.Modal``, ``bootstrap.Tooltip``, etc. (no ``$.fn.modal``).
* The portal's own scripts still depend on jQuery; your custom JS can
  continue to use it.


See also
--------

* :doc:`portalcustom` — general portal customization
* :doc:`upgrade_templates` — template upgrade notes per release
