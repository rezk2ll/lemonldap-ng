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

## @method boolean deleteCasSecondarySessions(string session_id)
# Find and delete CAS sessions bounded to a primary session
# @param session_id Primary session ID
# @return result
sub deleteCasSecondarySessions {
    my ( $self, $session_id ) = splice @_;
    my $result = 1;

    # Find CAS sessions
    my $cas_sessions =
      $self->{casStorage}
      ->searchOn( $self->{casStorageOptions}, "_cas_id", $session_id );

    if ( my @cas_sessions_keys = keys %$cas_sessions ) {

        foreach my $cas_session (@cas_sessions_keys) {

            # Get session
            $self->lmLog( "Retrieve CAS session $cas_session", 'debug' );

            my $casSessionInfo = $self->getSamlSession($cas_session);

            # Delete session
            eval { tied(%$casSessionInfo)->delete() };

            if ($@) {
                $self->lmLog( "Unable to delete CAS session $cas_session: $@",
                    'error' );
                $result = 0;
            }
            else {
                $self->lmLog( "CAS session $cas_session deleted", 'debug' );
            }

        }
    }
    else {
        $self->lmLog( "No CAS session found for session $session_id ",
            'debug' );
    }

    return $result;

}

1;

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

=head2 deleteCasSecondarySessions

Find and delete CAS sessions bounded to a primary session

=head1 SEE ALSO

L<Lemonldap::NG::Portal::IssuerDBCAS>

=head1 AUTHOR

Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

