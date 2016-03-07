# Lemonldap::NG::Portal REST API

* protect some entry points by vhost access rules ?

## Accounts

* Create account: `/account`, attr: firstname, lastname, mail
* Validate account: `/account/validate`, attr: mail
* Show account: `/account/<@mail>`, attr: mail
* List accounts: `/account/all`

Examples:

* `/account`
* `/account/validate`
* `/account/dhwo@badwolf.org`
* `/account/all`

### Available verbs:

* `GET`: see above (show or list account)
* `POST /account`: creates a new account and send a confirmation mail to user



## Passwords

* Initialize password change: `/changePassword/init`, attr: mail
* Change password: `/changePassword/validate`, attr: mail, newpassword, [random]

Examples:

* `/changePassword/init`
* `/changePassword/validate`

### Available verbs:

* `POST /changePassword/init`: initialize a password change (sends a mail to user)
* `POST /changePassword/validate`: finalize the password change (sends a mail to user)
* `POST /changePassword/validate?force=1`: do the password change even if not initialized (sends a mail to user)
