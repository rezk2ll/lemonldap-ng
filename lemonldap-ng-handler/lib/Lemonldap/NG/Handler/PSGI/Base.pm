package Lemonldap::NG::Handler::PSGI::Base;

use 5.10.0;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv :variables :jailSharedVars);

our $VERSION = '1.9.0';

has protection => ( is => 'rw', isa => 'Str' );

sub init {
    my ( $self, $args ) = @_;
    eval { Lemonldap::NG::Handler::SharedConf->init($self) };
    if ( $@ and not $self->{protection} eq 'none' ) {
        $self->error($@);
        return 0;
    }
    unless ( Lemonldap::NG::Handler::SharedConf->checkConf($self)
        or $self->{protection} eq 'none' )
    {
        $self->error(
            "Unable to protect this app ($Lemonldap::NG::Common::Conf::msg)");
        return 0;
    }
    return 1;
}

sub _run {
    my $self = shift;

    # Override _run() only if protection != 'none'
    my $rule = $self->{protection} || $localConfig->{protection};
    if ( $rule ne 'none' ) {
        $self->lmLog( 'PSGI app is protected', 'debug' );
        $rule =
          $rule eq "authenticate" ? "accept" : $rule eq "manager" ? "" : $rule;

        # Handle requests
        # Developers, be careful: Only this part is executed at each request
        return sub {
            return $self->_authAndTrace(
                Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );
        };
    }

    else {
        $self->lmLog( 'PSGI app is not protected', 'debug' );
        unless (%$tsv) {
            $self->lmLog( 'Checking conf', 'debug' );
            eval { Lemonldap::NG::Handler::SharedConf->checkConf() };
            $self->lmLog( $@, 'error' ) if ($@);
        }

        # Handle unprotected requests
        return sub {
            $self->router( Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );
        };
    }
}

sub _authAndTrace {
    my ( $self, $req ) = @_;
    Lemonldap::NG::Handler::API->newRequest($req);
    my $res = Lemonldap::NG::Handler::SharedConf->run( $self->{protection}
          || $localConfig->{protection} );
    $req->userData($datas) if ($datas);

    if ( $res < 300 ) {
        $self->lmLog( 'User authenticated, calling router()', 'debug' );
        return $self->router($req);
    }

    # Ajax hook: Ajax requests can not understand 30x responses. This
    #            is not really HTTP compliant but nothing in this
    #            protocol can do this. Our javascripts understand that
    #            they have to prompt user with the URL
    elsif (
        $req->accept =~ m|application/json|
        or (    $req->contentType
            and $req->contentType =~ m|application/json| )
      )
    {
        $self->lmLog( 'Ajax request detected', 'debug' );
        if ( $res == 302 or $res == 303 ) {
            $self->lmLog( 'Rewrite redirection to 401 response', 'debug' );
            return [
                401, [ Authorization => $req->{respHeaders}->{Location} ], ['']
            ];
        }
        else {
            $self->lmLog(
                "Lemonldap::NG::Handler::SharedConf::run() returns $res",
                'debug' );
            return [
                $res, [ 'Content-Type', 'application/json' ],
                [qq({"error":"$res"})]
            ];
        }
    }

    # Non Ajax requests may be redirected to portal
    else {
        my %h = $req->{respHeaders} ? %{ $req->{respHeaders} } : ();
        my $s = $tsv->{portal}->() . "?lmError=$res";
        $s =
            '<html><head><title>Redirection</title></head><body>'
          . qq{<script type="text/javascript">window.location='$s'</script>}
          . '<h1>Please wait</h1>'
          . qq{<p>An error occurs, you're going to be redirected to <a href="$s">$s</a>.</p>}
          . '</body></html>';
        $h{'Content-Type'}   = 'text/html';
        $h{'Content-Length'} = length $s;
        return [ $res, [%h], [$s] ];
    }
}

## @method hashRef user()
# @return hash of user datas
sub user {
    my ( $self, $req ) = @_;
    return $req->userData || { _whatToTrace => 'anonymous' };
}

## @method string userId()
# @return user identifier to log
sub userId {
    my ( $self, $req ) = @_;
    return $req->userData->{_whatToTrace} || 'anonymous';
}

## @method boolean group(string group)
# @param $group name of the Lemonldap::NG group to test
# @return boolean : true if user is in this group
sub group {
    my ( $self, $req, $group ) = @_;
    return () unless ( $req->userData->{groups} );
    return ( $req->userData->{groups} =~ /\b$group\b/ );
}

## @method PSGI::Response sendError($req,$err,$code)
# Add user di to $err before calling Lemonldap::NG::Common::PSGI::sendError()
# @param $req Lemonldap::NG::Common::PSGI::Request
# @param $err String to push
# @code int HTTP error code (default to 500)
sub sendError {
    my ( $self, $req, $err, $code ) = @_;
    $err ||= $req->error;
    $err = '[' . $self->userId($req) . "] $err";
    return $self->Lemonldap::NG::Common::PSGI::sendError( $req, $err, $code );
}
1;
