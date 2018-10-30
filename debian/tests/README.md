# lemonldap-ng autopkgtest

This autopkgtest configuration overrides pkg-perl-autopkgtest/runner to launch
`smoke` and `use.t` for each lemonldap-ng component. `syntax.t` is launched as
usual.

This `runner` uses `debian/tests/pkg-perl/lemonldap-ng-_<component>.<filename>`
instead of classic `smoke.files`,… So it is possible to define `smoke.*` or
`SKIP` files separately for each component _(but of course not syntax.skip)_.
