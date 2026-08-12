## @file
# LDAP storage methods for notifications

## @class
# LDAP storage methods for notifications

package Lemonldap::NG::Common::Notifications::LDAP;

use strict;
use Mouse;
use Time::Local;
use MIME::Base64 qw/encode_base64url/;
use IO::Socket::Timeout;
use Net::LDAP;

our $VERSION = '3.0.0';

extends 'Lemonldap::NG::Common::Notifications';

has ldap => (
    is      => 'ro',
    lazy    => 1,
    builder => 'newLdap'
);

has ldapServer => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapServer};
    }
);

has ldapPort => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapPort};
    }
);

has ldapCAFile => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapCAFile};
    }
);

has ldapCAPath => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapCAPath};
    }
);

has ldapVerify => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapVerify};
    }
);

has ldapConfBase => (
    is      => 'ro',
    trigger => sub {
        if ( my $table = $_[0]->{table} ) {
            $_[0]->{ldapConfBase} =~ s/^\w+=\w+(,.*)$/ou=$table$1/;
        }
    }
);

has ldapBindDN => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{managerDn};
    }
);

has ldapBindPassword => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{managerPassword};
    }
);

has ldapClientCert => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapClientCert};
    }
);

has ldapClientKey => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapClientKey};
    }
);

has ldapVersion => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapVersion} || '3';
    }
);

has ldapTimeout => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapTimeout} || 0;
    }
);

has ldapIOTimeout => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{ldapIOTimeout} || 0;
    }
);

# Returns notifications corresponding to the user $uid.
# If $ref is set, returns only notification corresponding to this reference.
sub get {
    my ( $self, $uid, $ref ) = @_;
    return () unless $uid;

    my $filter =
        '(&(objectClass=applicationProcess)(!(description={done}*))'
      . "(description={uid}$uid)"
      . ( $ref ? '(description={ref}' . $ref . ')' : '' ) . ')';
    my @entries = $self->_search($filter);
    my $result;

    foreach my $entry (@entries) {
        my @notifValues = $entry->get_value('description');
        my $f           = {};
        foreach (@notifValues) {
            my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/smg );
            $f->{$k} = $v;
        }
        my $content = $f->{content};
        my $identifier =
          $self->getIdentifier( $f->{uid}, $f->{ref}, $f->{date} );
        $result->{$identifier} = "$content";
        $self->logger->info("Notification $identifier found");

    }

    return $result;
}

# Returns accepted notifications corresponding to the user $uid.
# If $ref is set, returns only notification corresponding to this reference.
sub getAccepted {
    my ( $self, $uid, $ref ) = @_;
    return () unless $uid;

    my $filter =
        '(&(objectClass=applicationProcess)(description={done}*)'
      . "(description={uid}$uid)(description={ref}$ref))";
    my @entries = $self->_search($filter);
    my $result;

    foreach my $entry (@entries) {
        my @notifValues = $entry->get_value('description');
        my $f           = {};
        foreach (@notifValues) {
            my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/smg );
            $f->{$k} = $v;
        }
        my $content = $f->{content};
        my $identifier =
          $self->getIdentifier( $f->{uid}, $f->{ref}, $f->{date} );
        $result->{$identifier} = "$content";
        $self->logger->info("Notification $identifier found");

    }

    return $result;
}

## @method hashref getAll()
# Return all pending notifications.
# @return hashref where keys are internal reference and values are hashref with
# keys date, uid, ref and condition.
sub getAll {
    my $self    = shift;
    my @entries = $self->_search(
        '(&(objectClass=applicationProcess)(!(description={done}*)))');
    my $result = {};

    foreach my $entry (@entries) {
        my @notifValues = $entry->get_value('description');
        my $f           = {};
        foreach (@notifValues) {
            my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/smg );
            $f->{$k} = $v;
        }
        $result->{"$f->{date}#$f->{uid}#$f->{ref}"} = {
            date      => $f->{date},
            uid       => $f->{uid},
            ref       => $f->{ref},
            condition => $f->{cond},
        };
    }

    return $result;
}

## @method hashref getExisting()
# Return all notifications.
# @return hashref where keys are internal reference and values are hashref with
# keys date, uid, ref and condition.
sub getExisting {
    my $self    = shift;
    my @entries = $self->_search('objectClass=applicationProcess');
    my $result  = {};

    foreach my $entry (@entries) {
        my @notifValues = $entry->get_value('description');
        my $f           = {};
        foreach (@notifValues) {
            my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/smg );
            $f->{$k} = $v;
        }
        $result->{"$f->{date}#$f->{uid}#$f->{ref}"} = {
            date      => $f->{date},
            uid       => $f->{uid},
            ref       => $f->{ref},
            condition => $f->{cond},
        };
    }

    return $result;
}

## @method boolean delete(string myref)
# Mark a notification as done.
# @param $myref identifier returned by get() or getAll()
sub delete {
    my ( $self, $myref ) = @_;
    my ( $d, $u, $r );
    unless ( ( $d, $u, $r ) = ( $myref =~ /^([^#]+)#(.+?)#(.+)$/ ) ) {
        $self->logger->warn("Bad reference $myref");
        return 0;
    }
    my @ts = localtime();
    $ts[5] += 1900;
    $ts[4]++;
    return $self->_modify(
        '(&(objectClass=applicationProcess)'
          . "(description={uid}$u)"
          . "(description={ref}$r)"
          . "(description={date}$d)"
          . '(!(description={done}*)))',
        "description",
        "{done}$ts[5]-$ts[4]-$ts[3] $ts[2]:$ts[1]"
    );
}

## @method boolean purge(string myref, boolean force)
# Purge notification (really delete record)
# @param $myref identifier returned by get or getAll
# @param $force force purge for not deleted session
# @return true if something was deleted
sub purge {
    my ( $self, $myref, $force ) = @_;
    my ( $d, $u, $r );

    unless ( ( $d, $u, $r ) = ( $myref =~ /^([^#]+)#(.+?)#(.+)$/ ) ) {
        $self->logger->warn("Bad reference $myref");
        return 0;
    }

    my $clause = ( $force ? '' : '(description={done}*)' );
    return $self->_delete( '(&(objectClass=applicationProcess)'
          . "(description={uid}$u)"
          . "(description={ref}$r)"
          . "(description={date}$d)"
          . "$clause)" );
}

# Insert a new notification
# @param date Date
# @param uid UID
# @param ref Reference of the notification
# @param condition Condition for the notification
# @param content Content of the notification
# @return true if succeed
sub newNotif {
    my ( $self, $date, $uid, $ref, $condition, $content ) = @_;
    my $fns = $self->conf->{fileNameSeparator};
    $fns ||= '_';
    my @t = split( /\D+/, $date );
    $t[1]--;
    eval {
        timelocal( $t[5] || 0, $t[4] || 0, $t[3] || 0, $t[2], $t[1], $t[0] );
    };
    return ( 0, "Bad date" ) if ($@);
    $date =~ s/-//g;
    return ( 0, "Bad date" ) unless ( $date =~ /^\d{8}/ );
    my $cn = "${date}${fns}${uid}${fns}" . encode_base64url( $ref, '' );
    $cn .= "${fns}" . encode_base64url( $condition, '' ) if $condition;

    my $fields =
      $condition =~ /.+/
      ? {
        "date"    => "$date",
        "uid"     => "$uid",
        "ref"     => "$ref",
        "content" => "$content",
        "cond"    => "$condition",
      }
      : {
        "date"    => "$date",
        "uid"     => "$uid",
        "ref"     => "$ref",
        "content" => "$content",
      };

    return $self->_store( $cn, $fields );
}

## @method hashref getDone()
# Returns a list of notifications that have been done
# @return hashref where keys are internal reference and values are hashref with
# keys notified, uid and ref.
sub getDone {
    my ($self) = @_;
    my @entries = $self->_search(
        '(&(objectClass=applicationProcess)(description={done}*))');
    my $result = {};

    foreach my $entry (@entries) {
        my @notifValues = $entry->get_value('description');
        my $f           = {};
        foreach (@notifValues) {
            my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/smg );
            $f->{$k} = $v;
        }
        my @t = split( /\D+/, $f->{done} );
        $t[1]--;
        my $done =
          eval { timelocal( $t[5], $t[4], $t[3], $t[2], $t[1], $t[0] ) };
        if ($@) {
            $self->logger->warn("Bad date: $f->{done}");
            return {};
        }
        $result->{"$f->{date}#$f->{uid}#$f->{ref}"} = {
            notified  => $done,
            uid       => $f->{uid},
            ref       => $f->{ref},
            condition => $f->{cond}
        };
    }

    return $result;
}

## @method object private _ldap()
# Return the ldap object (build it if needed).
# @param filter The LDAP filter to apply
# @return list of entries returned by the LDAP search (set of Net::LDAP::Entry)
sub _search {
    my ( $self, $filter ) = @_;
    my $search = $self->ldap->search(
        base   => $self->ldapConfBase,
        filter => "$filter",
        scope  => 'sub',
        attrs  => ['description'],
    );

    if ( $search->code ) {
        $self->logger->error( "search error: " . $search->error() );
        return ();
    }

    return $search->entries();
}

## @method object private _delete()
# Deletes the all entries found by the given LDAP filter
# @param filter The LDAP filter to apply
# @return 1 if operation success, else 0
sub _delete {
    my ( $self, $filter ) = @_;
    my @entries = $self->_search($filter);
    my $mesg    = {};

    foreach my $entry (@entries) {
        $mesg = $self->ldap->delete( $entry->dn() );
        $mesg->code && return 0;
    }

    return 1;
}

## @method object private _modify()
# add the given attribute value to all entries found by LDAP filter
# @param filter The LDAP filter to apply
# @param attr : name of the attribute to modify
# @param value : new value to add
# @return 1 if operation success, else 0
sub _modify {
    my ( $self, $filter, $attr, $value ) = @_;
    my @entries = $self->_search($filter);
    my $mesg    = {};

    foreach my $entry (@entries) {
        $mesg =
          $self->ldap->modify( $entry->dn(), add => { $attr => $value }, );
        $mesg->code && return 0;
    }

    return 1;
}

## @method object private _store()
# creates the notification defined by dn: cn=$cn,$ldapConfBase and $fields
# stored in the description attribute
# @param cn : cn value, used as a dn component
# @param fields : set of values to store in description attribute
# @return 1 if operation success, else 0
sub _store {
    my ( $self, $cn, $fields ) = @_;
    my $notifName = $cn;
    my $notifDN   = "cn=$notifName," . $self->ldapConfBase;

    # Store values as {key}value
    my @notifValues;
    foreach my $k ( keys %$fields ) {
        my $v = $fields->{$k};
        push @notifValues, "{$k}$v";
    }

    my $add = $self->ldap->add(
        $notifDN,
        attrs => [
            objectClass => [ 'top', 'applicationProcess' ],
            cn          => $notifName,
            description => \@notifValues,
        ]
    );

    if ( $add->code ) {
        $self->logger->error( $add->error );
        return 0;
    }

    return 1;
}

## @method string getIdentifier(string uid, string ref, string date)
# Get notification identifier
# @param $uid uid
# @param $ref ref
# @param $date date
# @return the notification identifier
sub getIdentifier {
    my ( $self, $uid, $ref, $date ) = @_;
    return $date . "#" . $uid . "#" . $ref;
}

sub newLdap {
    my $self = shift;
    my ( @servers, %tlsParams, $useStartTls );

    foreach my $server ( split /[\s,]+/, $self->ldapServer ) {
        if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
            $useStartTls = 1;
            $server      = $1;
            %tlsParams   = split( /[&=]/, $2 || "" );
        }
        elsif ( $server =~ m{^(ldaps://[^/]+)/?\??(.*)$} ) {
            $useStartTls = 0;
            $server      = $1;
            %tlsParams   = split( /[&=]/, $2 || "" );
        }
        else {
            $useStartTls = 0;
        }
        push @servers, $server;
    }

    $tlsParams{cafile} ||= $self->ldapCAFile if $self->ldapCAFile;
    $tlsParams{capath} ||= $self->ldapCAPath if $self->ldapCAPath;
    $tlsParams{verify} ||= $self->ldapVerify if $self->ldapVerify;
    eval { require Authen::SASL if $self->ldapClientCert; };
    if ($@) {
        $self->logger->error(
            "Authen::SASL is required to connect using mTLS ($@)");
        undef $tlsParams{clientcert};
    }
    else {
        $tlsParams{clientcert} ||= $self->ldapClientCert
          if $self->ldapClientCert;
        $tlsParams{clientkey} ||= $self->ldapClientKey
          if $self->ldapClientKey;
    }

    my $ldap = Net::LDAP->new(
        \@servers,
        onerror   => undef,
        keepalive => 1,
        raw       => qr/(?i:^jpegPhoto|;binary)/,
        %tlsParams,
        ( $self->ldapPort    ? ( port    => $self->ldapPort )    : () ),
        ( $self->ldapTimeout ? ( timeout => $self->ldapTimeout ) : () ),
        ( $self->ldapVersion ? ( version => $self->ldapVersion ) : () ),
    );

    unless ($ldap) {
        die 'Connection failed: ' . $@;
    }
    elsif ( $Net::LDAP::VERSION < '0.64' ) {

        # CentOS7 has a bug in which IO::Socket::SSL will return a broken
        # socket when certificate validation fails. Net::LDAP does not catch
        # it, and the process ends up crashing.
        # As a precaution, make sure the underlying socket is doing fine:
        if (    $ldap->socket->isa('IO::Socket::SSL')
            and $ldap->socket->errstr )
        {
            die "SSL connection error: " . $ldap->socket->errstr;
        }
    }

    # Set socket timeouts
    my $socket = $ldap->socket;
    IO::Socket::Timeout->enable_timeouts_on($socket);
    $socket->read_timeout( $self->ldapIOTimeout );
    $socket->write_timeout( $self->ldapIOTimeout );

    if ($useStartTls) {
        my $mesg = $ldap->start_tls(%tlsParams);
        die 'TLS failed: ' . $mesg->error if ( $mesg->code );
    }

    my $bind = $self->_bind( $ldap, $tlsParams{clientcert} );
    if ( $bind->code ) {
        die 'Bind failed: ' . $bind->error;
    }

    return $ldap;
}

sub _bind {
    my ( $self, $ldap, $sasl ) = @_;

    if ( $self->ldapBindDN && $self->ldapBindPassword ) {
        $self->logger->debug( 'Call bind for ' . $self->ldapBindDN );
        return $ldap->bind( $self->ldapBindDN,
            password => $self->ldapBindPassword );
    }
    elsif ( $self->ldapClientCert && $self->ldapClientKey && $sasl ) {
        my $sasl = Authen::SASL->new(
            mechanism => 'EXTERNAL',
            callback  => { user => '' }
        );
        $self->logger->debug('Call mTLS bind');
        return $ldap->bind( undef, sasl => $sasl );
    }
    else {
        $self->logger->debug('Call anonymous bind');
        return $ldap->bind();
    }
}

1;
