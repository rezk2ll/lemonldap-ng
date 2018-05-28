LLNG team scripts
-----------------

## Release tools
* `parameters-for-wiki.pl`: generates the content of `https://lemonldap-ng.org/documentation/<VERSION>/parameterlist`
* `changelibversion`: changes $VERSION in all `.pm` files and also in `*/Makefile.PL` _(after major release)_
* `generate-changelog.pl`: generates `changelog` entry from [GitLab issues](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues)

## Tools used by Makefile
* `doc.pl`: launched by `make documentation` to create local doc
* `jsongenerator.pl`: launched by `make json` to build Manager JSON files and some Perl scripts
* `transform-templates`: transform `*.tpl` to choose normal/minified/external CSS/JavaScripts

## Other tools
* `testConfBackend.pl`: test a new configuration backend
* `test-perf.pl`: little script to test Portal/Handler performance
* `totp-client.pl`: TOTP app to replace FreeOTP for TOTP tests
* `run-ldap`: Launch an LDAP server (port 19389) and stop it when a key is pressed. It uses Portal test LDAP server.

## Old unmaintained scripts
* `copyright-updater.pl`: old script used to replace CHANGELOG POD entry
* `findAttr.pl`: may find some undocumented parameters
* `minifierskin`
* `unaccent.pl`
