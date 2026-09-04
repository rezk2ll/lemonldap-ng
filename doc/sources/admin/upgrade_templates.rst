Template updates
================

.. note::

    The content of this page only applies to you if:

    * You are using a custom LemonLDAP::NG theme
    * AND you modified some of LemonLDAP::NG's base templates (``login.tpl``, etc.).

    Note that templates whose name start with ``custom`` (``customfooter.tpl``, etc.) do NOT count.

    In other words, you can safely ignore this entire page if:

    * You only changed the logo or background
    * OR you created a custom theme and the only templates you modified are the ones that start with ``custom`` (``customfooter.tpl``, etc.)


3.0
---

``bootstrap`` skin upgraded to Bootstrap 5
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The default ``bootstrap`` skin has been rebuilt on **Bootstrap 5.3 +
Font Awesome 6 Free** (it was previously Bootstrap 4) and is now built
from SCSS sources. The skin name is unchanged, so ``portalSkin =
bootstrap`` keeps working: standard deployments that did not fork the
templates need no action.

If you maintain a **custom skin derived from the old Bootstrap 4**
``bootstrap`` **skin**, you must port it to Bootstrap 5. See
:doc:`bootstrapskin` for the full migration checklist (class renames,
removed component wrappers, Font Awesome v4 → v6 notes).

The frontend dependency manager has switched from Bower to npm. If you
were running ``bower install`` to refresh the vendored libraries under
``site/htdocs/static/bwr/``, run ``make refresh_portal_vendor`` instead.

