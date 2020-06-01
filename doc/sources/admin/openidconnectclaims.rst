OpenID Connect claims
~~~~~~~~~~~~~~~~~~~~~

===================== ================ ======= =======================================
Claim name            Associated scope Type    Example of corresponding LDAP attribute
===================== ================ ======= =======================================
sub                   openid           string  uid
name                  profile          string  cn
given_name            profile          string  givenName
family_name           profile          string  sn
middle_name           profile          string
nickname              profile          string
preferred_username    profile          string  displayName
profile               profile          string  labeledURI
picture               profile          string
website               profile          string
email                 email            string  mail
email_verified        email            boolean
gender                profile          string
birthdate             profile          string
zoneinfo              profile          string
locale                profile          string  preferredLanguage
phone_number          phone            string  telephoneNumber
phone_number_verified phone            boolean
updated_at            profile          string
formatted             address          string  registeredAddress
street_address        address          string  street
locality              address          string  l
region                address          string  st
postal_code           address          string  postalCode
country               address          string  co
===================== ================ ======= =======================================
