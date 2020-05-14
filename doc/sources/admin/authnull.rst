Null
====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔     ✔
============== ===== ========

Presentation
------------

LL::NG Null backend is a transparent backend:

-  Authentication: will create session without prompting any credentials
   (but will register client IP and creation date)
-  Users: will not collect any data (but you can still register
   environment variables in session)
-  Password: will not change any password

You can use Null backend to bypass some authentication process steps.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Null for authentication, users or password module.

Then, go in ``Null parameters``:

-  **Authentication level**: authentication level for this module.
