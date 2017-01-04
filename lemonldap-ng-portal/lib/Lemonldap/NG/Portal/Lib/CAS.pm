package Lemonldap::NG::Portal::Lib::CAS;

use strict;
use Mouse;

our $VERSION = '2.0.0';

# PROPERTIES

# return LWP::UserAgent object
has ua => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {

        # TODO : LWP options to use a proxy for example
        my $ua = LWP::UserAgent->new();
        push @{ $ua->requests_redirectable }, 'POST';
        $ua->env_proxy();
        return $ua;
    }
);

# INITIALIZATION

sub sendSoapResponse {
    my ( $self, $req, $s ) = @_;
    return [ 200, [ 'Content-Length' => length($s) ], [$s] ];
}

# Try to recover the CAS session corresponding to id and return session datas
# If id is set to undef, return a new session
sub getCasSession {
    my ( $self, $id ) = @_;

    my $casSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->conf->{casStorage},
            storageModuleOptions => $self->conf->{casStorageOptions},
            cacheModule          => $self->conf->{localSessionStorage},
            cacheModuleOptions   => $self->conf->{localSessionStorageOptions},
            id                   => $id,
            kind                 => "CAS",
        }
    );

    if ( $casSession->error ) {
        if ($id) {
            $self->p->userInfo("CAS session $id isn't yet available");
        }
        else {
            $self->lmLog( "Unable to create new CAS session", 'error' );
            $self->lmLog( $casSession->error,                 'error' );
        }
        return undef;
    }

    return $casSession;
}

# Return an error for CAS VALIDATE request
sub returnCasValidateError {
    my ( $self, $req ) = @_;

    $self->lmLog( "Return CAS validate error", 'debug' );

    return [ 200, [ 'Content-Length' => 4 ], ["no\n\n"] ];
}

# Return success for CAS VALIDATE request
sub returnCasValidateSuccess {
    my ( $self, $req, $username ) = @_;

    $self->lmLog( "Return CAS validate success with username $username",
        'debug' );

    return $self->sendSoapResponse( $req, "yes\n$username\n" );
}

# Return an error for CAS SERVICE VALIDATE request
sub returnCasServiceValidateError {
    my ( $self, $req, $code, $text ) = @_;

    $code ||= 'INTERNAL_ERROR';
    $text ||= 'No description provided';

    $self->lmLog( "Return CAS service validate error $code ($text)", 'debug' );

    return $self->sendSoapResponse(
        $req, "<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
\t<cas:authenticationFailure code=\"$code\">
\t\t$text
\t</cas:authenticationFailure>
</cas:serviceResponse>\n"
    );
}

# Return success for CAS SERVICE VALIDATE request
sub returnCasServiceValidateSuccess {
    my ( $self, $req, $username, $pgtIou, $proxies, $attributes ) = @_;

    $self->lmLog( "Return CAS service validate success with username $username",
        'debug' );

    my $s = "<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
\t<cas:authenticationSuccess>
\t\t<cas:user>$username</cas:user>\n";
    if ( defined $attributes ) {
        $s .= "\t\t<cas:attributes>\n";
        foreach my $attribute ( keys %$attributes ) {
            foreach my $value (
                split(
                    $self->conf->{multiValuesSeparator},
                    $attributes->{$attribute}
                )
              )
            {
                $s .= "\t\t\t<cas:$attribute>$value</cas:$attribute>\n";
            }
        }
        $s .= "\t\t</cas:attributes>\n";
    }
    if ( defined $pgtIou ) {
        $self->lmLog( "Add proxy granting ticket $pgtIou in response",
            'debug' );
        $s .=
          "\t\t<cas:proxyGrantingTicket>$pgtIou</cas:proxyGrantingTicket>\n";
    }
    if ($proxies) {
        $self->lmLog( "Add proxies $proxies in response", 'debug' );
        $s .= "\t\t<cas:proxies>\n\t\t\t<cas:proxy>$_</cas:proxy>\n"
          foreach ( split( /$self->{multiValuesSeparator}/, $proxies ) );
        $s .= "\t\t</cas:proxies>\n";
    }
    $s .= "\t</cas:authenticationSuccess>\n</cas:serviceResponse>\n";

    return $self->sendSoapResponse( $req, $s );
}

# Return an error for CAS PROXY request
sub returnCasProxyError {
    my ( $self, $req, $code, $text ) = @_;

    $code ||= 'INTERNAL_ERROR';
    $text ||= 'No description provided';

    $self->lmLog( "Return CAS proxy error $code ($text)", 'debug' );

    return $self->sendSoapResponse(
        $req, "<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
\t<cas:proxyFailure code=\"$code\">
\t\t$text
\t</cas:proxyFailure>
</cas:serviceResponse>\n"
    );
}

# Return success for CAS PROXY request
sub returnCasProxySuccess {
    my ( $self, $req, $ticket ) = @_;

    $self->lmLog( "Return CAS proxy success with ticket $ticket", 'debug' );

    return $self->sendSoapResponse(
        $req, "<cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
\t<cas:proxySuccess>
\t\t<cas:proxyTicket>$ticket</cas:proxyTicket>
\t</cas:proxySuccess>
</cas:serviceResponse>\n"
    );
}

# Find and delete CAS sessions bounded to a primary session
sub deleteCasSecondarySessions {
    my ( $self, $session_id ) = @_;
    my $result = 1;

    # Find CAS sessions
    my $moduleOptions = $self->conf->{casStorageOptions} || {};
    $moduleOptions->{backend} = $self->conf->{casStorage};
    my $module = "Lemonldap::NG::Common::Apache::Session";

    my $cas_sessions =
      $module->searchOn( $moduleOptions, "_cas_id", $session_id );

    if ( my @cas_sessions_keys = keys %$cas_sessions ) {

        foreach my $cas_session (@cas_sessions_keys) {

            # Get session
            $self->lmLog( "Retrieve CAS session $cas_session", 'debug' );

            my $casSession = $self->getCasSession($cas_session);

            # Delete session
            $result = $self->deleteCasSession($casSession);
        }
    }
    else {
        $self->lmLog( "No CAS session found for session $session_id ",
            'debug' );
    }

    return $result;

}

# Delete an opened CAS session
sub deleteCasSession {
    my ( $self, $session ) = @_;

    # Check session object
    unless ( $session && $session->data ) {
        $self->lmLog( "No session to delete", 'error' );
        return 0;
    }

    # Get session_id
    my $session_id = $session->id;

    # Delete session
    unless ( $session->remove ) {
        $self->lmLog( $session->error, 'error' );
        return 0;
    }

    $self->lmLog( "CAS session $session_id deleted", 'debug' );

    return 1;
}

# Call proxy granting URL on CAS client
sub callPgtUrl {
    my ( $self, $pgtUrl, $pgtIou, $pgtId ) = @_;

    # Build URL
    my $url =
      $pgtUrl . ( $pgtUrl =~ /\?/ ? '&' : '?' ) . "pgtIou=$pgtIou&pgtId=$pgtId";

    $self->lmLog( "Call URL $url", 'debug' );

    # GET URL
    my $response = $self->ua->get($url);

    # Return result
    return $response->is_success();
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

=head2 returnCasServiceValidateError

Return an error for CAS SERVICE VALIDATE request

=head2 returnCasServiceValidateSuccess

Return success for CAS SERVICE VALIDATE request

=head2 returnCasProxyError

Return an error for CAS PROXY request

=head2 returnCasProxySuccess

Return success for CAS PROXY request

=head2 deleteCasSession

Delete an opened CAS session

=head2 callPgtUrl

Call proxy granting URL on CAS client

=head1 SEE ALSO

L<Lemonldap::NG::Portal::IssuerDBCAS>

=head1 AUTHORS

=over

=item LemonLDAP::NG team L<http://lemonldap-ng.org/team>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

See COPYING file for details.

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
