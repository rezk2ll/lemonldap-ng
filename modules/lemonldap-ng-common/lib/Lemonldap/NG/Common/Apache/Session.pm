package Lemonldap::NG::Common::Apache::Session;

use Storable qw(thaw);

BEGIN {

    sub Apache::Session::get_key_from_all_sessions {
        return 0;
    }

    sub Apache::Session::MySQL::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;
        my $data  = shift;

	# TODO : replace die by abort
        my $dbh =
          DBI->connect( $args->{DataSource}, $args->{UserName},
            $args->{Password} )
          or die("$!$@");
        my $sth = $dbh->prepare('SELECT id,a_session from sessions');
        $sth->execute;
        my %res;
        while ( my @row = $sth->fetchrow_array ) {
            if ( ref($data) eq 'CODE' ) {
                my $tmp = &$data( thaw( $row[1] ), $row[0] );
                $res{ $row[0] }->{$_} = $tmp if ( defined($tmp) );
            }
            elsif ($data) {
                $data = [$data] unless ( ref($data) );
                my $tmp = thaw( $row[1] );
                $res{ $row[0] }->{$_} = $tmp->{$_} foreach (@$data);
            }
            else {
                $res{ $row[0] } = thaw( $row[1] );
            }
        }
        return \%res;
    }

    *Apache::Session::Postgres::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Oracle::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Sybase::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Informix::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;

    sub Apache::Session::File::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;
        my $data  = shift;
        $args->{Directory} ||= '/tmp';

	# TODO : replace die by abort
        unless ( opendir DIR, $args->{Directory} ) {
            die "Cannot open directory $args->{Directory}\n";
        }
        my @t =
          grep { -f "$args->{Directory}/$_" and /^[A-Za-z0-9@\-]+$/ }
          readdir(DIR);
        closedir DIR;
        my %res;
        for my $f (@t) {
            open F, "$args->{Directory}/$f";
            my $row = join '', <F>;
            if ( ref($data) eq 'CODE' ) {
                $res{$f}->{$_} = &$data( thaw($row), $f );
            }
            elsif ($data) {
                $data = [$data] unless ( ref($data) );
                my $tmp = thaw($row);
                $res{$f}->{$_} = $tmp->{$_} foreach (@$data);
            }
            else {
                $res{$f} = thaw($row);
            }
        }
        return \%res;
    }

    sub Apache::Session::DB_File::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;

        if ( !tied %{ $class->{dbm} } ) {
            my $rv = tie %{ $class->{dbm} }, 'DB_File', $args->{FileName};

	    # TODO : replace die by abort
            if ( !$rv ) {
                die "Could not open dbm file " . $args->{FileName} . ": $!";
            }
        }
        return keys( %{ $class->{dbm} } );
    }
}

1;
