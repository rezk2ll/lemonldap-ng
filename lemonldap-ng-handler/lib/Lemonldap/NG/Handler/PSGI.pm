package Lemonldap::NG::Handler::PSGI;

use 5.10.0;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv :variables :jailSharedVars);
extends 'Lemonldap::NG::Common::PSGI::Router';

our $VERSION = '1.9.0';

around init => sub {
    my ( $method, $self, $args ) = splice @_;
    Lemonldap::NG::Handler::SharedConf->init($self);
    Lemonldap::NG::Handler::SharedConf->checkConf($self);
    return $self->$method($args);
};

sub _run {
    my $self = shift;
    my $rule = $self->{protection} || $localConfig->{protection};
    if ( $rule ne 'none' ) {
        $rule =
          $rule eq "authenticate" ? "accept" : $rule eq "manager" ? "" : $rule;
        return sub {
            my $req = Lemonldap::NG::Common::PSGI::Request->new( $_[0] );
            Lemonldap::NG::Handler::API->newRequest($req);
            my $res = Lemonldap::NG::Handler::SharedConf->run($rule);
            $req->userData($datas) if ($datas);

            # TODO: Userdata
            #print STDERR Dumper( \@_, $res ); use Data::Dumper;
            if ( $res == 403 ) {
                return [
                    403,
                    [ 'Content-Type' => 'text/plain' ],
                    ["You don't have rights to access this page"]
                ];
            }

            # Ajax hook: Ajax requests can not understand 30x responses. This
            #            is not really HTTP compliant but nothing in this
            #            protocol can do this. Our javascript understand that
            #            it has to prompt user with the URL
            elsif (
                ( $res == 302 or $res == 303 )
                and (
                    $req->accept =~ m|application/json|
                    or (    $req->contentType
                        and $req->contentType =~ m|application/json| )
                )
              )
            {
                return [
                    401, [ Authorization => $req->{respHeaders}->{Location} ],
                    ['']
                ];
            }
            elsif ($res) {
                return [ $res, [ %{ $req->{respHeaders} } ], [''] ];
            }
            else {
                return $self->router($req);
            }
        };
    }
    else {
        eval { Lemonldap::NG::Handler::SharedConf->checkConf() } unless (%$tsv);
        $self->lmLog( $@, 'error' ) if ($@);
        return sub {

            #print STDERR Dumper(\@_);use Data::Dumper;
            $self->router( Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );
        };
    }
}

## @method hashRef user()
# @return hash of user datas
sub user {
    my ( $self, $req ) = splice @_;
    return $req->userData || { _whatToTrace => 'anonymous' };
}

## @method string userId()
# @return user identifier to log
sub userId {
    my ( $self, $req ) = splice @_;
    return $req->userData->{_whatToTrace} || 'anonymous';
}

## @method boolean group(string group)
# @param $group name of the Lemonldap::NG group to test
# @return boolean : true if user is in this group
sub group {
    my ( $self, $req, $group ) = splice @_;
    return () unless ( $req->userData->{groups} );
    return ( $req->userData->{groups} =~ /\b$group\b/ );
}

## @method PSGI::Response sendError($req,$err,$code)
# Add user di to $err before calling Lemonldap::NG::Common::PSGI::sendError()
# @param $req Lemonldap::NG::Common::PSGI::Request
# @param $err String to push
# @code int HTTP error code (default to 500)
sub sendError {
    my ( $self, $req, $err, $code ) = splice @_;
    $err ||= $req->error;
    $err = '[' . $self->userId($req) . "] $err";
    return $self->SUPER::sendError( $req, $err, $code );
}

1;
