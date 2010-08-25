## @file
# Common CAS functions

## @class
# Common CAS functions
package Lemonldap::NG::Portal::_CAS;

use strict;

our $VERSION = '0.01';

## @method hashref getCasSession(string id)
# Try to recover the CAS session corresponding to id and return session datas
# If id is set to undef, return a new session
# @param id session reference
# @return session datas
sub getCasSession {
    my ( $self, $id ) = splice @_;
    my %h;

    # Trying to recover session from CAS session storage
    eval { tie %h, $self->{casStorage}, $id, $self->{casStorageOptions}; };
    if ( $@ or not tied(%h) ) {

        # Session not available
        if ($id) {
            $self->lmLog( "CAS session $id isn't yet available", 'info' );
        }
        else {
            $self->lmLog( "Unable to create new CAS session: $@", 'error' );
        }
        return 0;
    }

    return \%h;
}

## @method void returnCasValidateError()
# Return an error for CAS VALIDATE request
# @return nothing
sub returnCasValidateError {
    my ($self) = splice @_;

    print $self->header();
    print "no\n\n";

    $self->quit();
}

## @method void returnCasValidateSuccess(string username)
# Return success for CAS VALIDATE request
# @param username User name
# @return nothing
sub returnCasValidateSuccess {
    my ( $self, $username ) = splice @_;

    print $self->header();
    print "yes\n$username\n";

    $self->quit();
}

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::_CAS - Common CAS functions

=head1 SYNOPSIS

use Lemonldap::NG::Portal::_CAS;

=head1 DESCRIPTION

This module contains common methods for CAS

=head1 METHODS

=head2 getCasSession

Try to recover the CAS session corresponding to id and return session datas
If id is set to undef, return a new session

=head2 returnCasValidateError

Return an error for CAS VALIDATE request

=head2 returnCasValidateSuccess

Return success for CAS VALIDATE request

=head1 SEE ALSO

L<Lemonldap::NG::Portal::IssuerDBCAS>,

=head1 AUTHOR

Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

