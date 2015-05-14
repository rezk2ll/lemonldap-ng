package Lemonldap::NG::Manager::ConfParser;

use Mouse;
use Lemonldap::NG::Manager::Constants;
use Lemonldap::NG::Manager::Attributes;

has errors   => ( is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has warnings => ( is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has changes  => ( is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has needConfirm =>
  ( is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has message     => ( is => 'rw', isa => 'Str',     default  => '' );
has confChanged => ( is => 'rw', isa => 'Int',     default  => 0 );
has refConf     => ( is => 'ro', isa => 'HashRef', required => 1 );
has req     => ( is => 'ro', required => 1 );
has newConf => ( is => 'rw', isa      => 'HashRef' );
has tree    => ( is => 'rw', isa      => 'ArrayRef' );

sub check {
    my $self = shift;
    my $res;
    unless ( $self->newConf ) {
        $res = $self->scanTree;
        return 0 unless ($res);
    }

    unless ( $self->testNewConf ) {
        return 0;
    }
    $self->message('__confNotChanged__') unless ( $self->confChanged );
    return ( $self->confChanged );
}

# Methods to buid conf from JSON tree

# JSON parser launcher
sub scanTree {
    my $self = shift;
    $self->newConf( {} );
    $self->_scanNodes( $self->tree ) or return 0;

    # Set cfgNum to ref cfgNum (will be changed when saving), set other
    # metadatas and set a value to the key if empty
    $self->newConf->{cfgNum}      = $self->refConf->{cfgNum};
    $self->newConf->{cfgAuthor}   = 'TODO';
    $self->newConf->{cfgAuthorIP} = $self->req->remote_ip;
    $self->newConf->{cfgDate}     = time;
    $self->newConf->{key} ||=
      join( '', map { chr( int( rand(94) ) + 33 ) } ( 1 .. 16 ) );

    # TODO: set metadatas
    return 1;
}

use feature 'state';

# Recursive JSON parser
sub _scanNodes {
    my ( $self, $tree, ) = splice @_;
    state( $knownCat, %newNames );
    unless ( ref($tree) eq 'ARRAY' ) {
        print STDERR 'Fatal: node is not an array';
        push @{ $self->errors }, { message => 'Fatal: node is not an array' };
        return 0;
    }
    foreach my $leaf (@$tree) {
        my $name = $leaf->{title};

        # subnode
        my $subNodes     = $leaf->{nodes}      // $leaf->{_nodes};
        my $subNodesCond = $leaf->{nodes_cond} // $leaf->{_nodes_cond};

        ##################################
        # VirtualHosts and SAML partners #
        ##################################

        # Root nodes
        if ( $leaf->{id} =~ /^($specialNodeKeys)$/io ) {

            # If node has not been opened
            if ( $leaf->{cnodes} ) {
                foreach my $k ( @{ $specialNodeHash->{ $leaf->{id} } } ) {
                    $self->newConf->{$k} = $self->refConf->{$k};
                }
                next;
            }
            $self->_scanNodes($subNodes);

            # Check deleted keys
            my $field = $specialNodeHash->{ $leaf->{id} }->[0];
            my @old   = keys %{ $self->refConf->{$field} };
            foreach my $k ( keys %{ $self->newConf->{$field} } ) {
                @old = grep { $_ ne $k } @old;
            }
            if (@old) {
                $self->confChanged(1);
                foreach my $deletedHost (@old) {
                    push @{ $self->changes },
                      { key => $leaf->{id}, old => $deletedHost };
                }
            }
            next;
        }

        # 1st sublevel
        elsif ( $leaf->{id} =~ /^($specialNodeKeys)\/([^\/]+)$/io ) {
            my ( $base, $host ) = ( $1, $2 );

            # Check hostname/partner name changes (id points to the old name)
            $newNames{$host} = $leaf->{title};

            $self->_scanNodes($subNodes);
            next;
        }

        # Other sub levels
        elsif ( $leaf->{id} =~
            /^($specialNodeKeys)\/([^\/]+)\/([^\/]+)(?:\/(.*))?$/io )
        {
            my ( $base, $key, $target, $h ) = ( $1, $newNames{$2}, $3, $4 );

            # VirtualHosts
            if ( $base eq 'virtualHosts' ) {
                if ( $target =~ /^(?:locationRules|exportedHeaders|post)$/ ) {
                    if (    $target eq 'post'
                        and defined $leaf->{data}
                        and ref( $leaf->{data} ) eq 'ARRAY' )
                    {
                        $leaf->{data} = join '|', @{ $leaf->{data} };
                    }
                    if ( $leaf->{cnodes} ) {
                        $self->newConf->{$target}->{$key} =
                          $self->refConf->{$target}->{$key} // {};
                    }

                    elsif ($h) {
                        if ( $target eq 'locationRules' ) {
                            my $k =
                              $leaf->{comment}
                              ? "(?#$leaf->{comment})$leaf->{re}"
                              : $leaf->{re};
                            $self->set( $target, $key, $k, $leaf->{data} );
                        }
                        else {
                            $self->set( $target, $key, $leaf->{title},
                                $leaf->{data} );
                        }
                    }

                    # Unless $h is set, scan subnodes and check changes
                    else {
                        if ( ref $subNodes ) {
                            $self->_scanNodes($subNodes)
                              or return 0;
                        }
                        if ( exists $self->refConf->{$target}->{$key}
                            and %{ $self->refConf->{$target}->{$key} } )
                        {
                            my $c = $self->newConf->{$target};
                            foreach my $k (
                                keys %{ $self->refConf->{$target}->{$key} } )
                            {
                                unless ( defined $c->{$key}->{$k} ) {
                                    $self->confChanged(1);
                                    push @{ $self->changes },
                                      {
                                        key => "$target, $key",
                                        old => $k,
                                      };
                                }
                            }
                        }
                        elsif ( exists $self->newConf->{$target}->{$key}
                            and %{ $self->newConf->{$target}->{$key} } )
                        {
                            $self->confChanged(1);
                            push @{ $self->changes },
                              { key => "$target", new => $key };
                        }
                    }
                }
                elsif ( $target =~ /^$virtualHostKeys$/o ) {
                    $self->set( 'vhostOptions', $key, $target, $leaf->{data} );
                }
                else {
                    push @{ $self->errors },
                      { message => "Unknown vhost key $target" };
                    return 0;
                }
                next;
            }
            if ( defined $leaf->{data} and ref( $leaf->{data} ) eq 'ARRAY' ) {
                $leaf->{data} = join ';', @{ $leaf->{data} };
            }

            # SAML
            if ( $base =~ /^saml(?:S|ID)PMetaDataNodes$/ ) {
                if ( $target =~ /^saml(?:S|ID)MetaDataExportedAttributes$/ ) {
                    if ( $leaf->{cnodes} ) {
                        $self->newConf->{$target}->{$key} =
                          $self->refConf->{$target}->{$key} // {};
                    }
                    if ($h) {
                        $self->set( $target, $key, $leaf->{title},
                            $leaf->{data} );
                    }
                }
                elsif ( $target =~ /^saml(?:S|ID)MetaDataXML$/ ) {
                    $self->set( $target, $key, $target, $leaf->{data} );
                }
                elsif ( $target =~
                    /^(?:$samlIDPMetaDataNodeKeys|$samlSPMetaDataNodeKeys)/o )
                {
                    $self->set( $base, $key, $target, $leaf->{data} );
                }
                else {
                    push @{ $self->errors },
                      { message => "Unknown vhost key $target" };
                    return 0;
                }
                next;
            }
        }

        ####################
        # Application list #
        ####################
        elsif ( $leaf->{id} =~ /^applicationList\/(.+)$/ ) {
            use feature 'state';
            my @cats = split /\//, $1;
            my $app = pop @cats;
            $self->newConf->{applicationList} //= {};

            # $cn is a pointer to the parent
            my $cn  = $self->newConf->{applicationList};
            my $cmp = $self->refConf->{applicationList};
            my @path;

            # Makes $cn point to the parent
            foreach my $cat (@cats) {
                unless ( defined $knownCat->{$cat} ) {
                    push @{ $self->{errors} },
                      { message =>
                          "Fatal: sub cat/app before parent ($leaf->{id})" };
                    return 0;
                }
                $cn = $cn->{ $knownCat->{$cat} };
                push @path, $cn->{catname};
                $cmp->{$cat} //= {};
                $cmp = $cmp->{$cat};
            }

            # Create new category
            #
            # Note that this works because nodes are ordered so "cat/cat2/app"
            # is looked after "cat" and "cat/cat2"
            if ( $leaf->{type} eq 'menuCat' ) {
                $knownCat->{__id}++;
                my $s = $knownCat->{$app} = sprintf '%04d-cat',
                  $knownCat->{__id};
                $cn->{$s} =
                  { catname => $leaf->{title}, type => 'category' };
                unless ($cmp->{$app}
                    and $cmp->{$app}->{catname} eq $cn->{$s}->{catname} )
                {
                    $self->confChanged(1);
                    push @{ $self->changes },
                      {
                        key => join(
                            ', ', 'applicationList', @path, $leaf->{title}
                        ),
                        new => $cn->{$s}->{catname},
                        old => ( $cn->{$s} ? $cn->{$s}->{catname} : undef )
                      };
                }
                if ( ref $subNodes ) {
                    $self->_scanNodes($subNodes) or return 0;
                }

                # TODO: check for deleted
            }

            # Create new apps
            else {
                $knownCat->{__id}++;
                my $name = sprintf( '%04d-app', $knownCat->{__id} );
                $cn->{$name} =
                  { type => 'application', options => $leaf->{data} };
                $cn->{$name}->{options}->{name} = $leaf->{title};
                unless ( $cmp->{$app} ) {
                    $self->confChanged(1);
                    push @{ $self->changes },
                      {
                        key => join( ', ', 'applicationList', @path ),
                        new => $leaf->{title},
                      };
                }
                else {
                    foreach my $k ( keys %{ $cn->{$name}->{options} } ) {
                        unless ( $cmp->{$app}->{options}->{$k} eq
                            $cn->{$name}->{options}->{$k} )
                        {
                            $self->confChanged(1);
                            push @{ $self->changes },
                              {
                                key => join( ', ',
                                    'applicationList', @path,
                                    $leaf->{title},    $k ),
                                new => $cn->{$name}->{options}->{$k},
                                old => $cmp->{$app}->{options}->{$k}
                              };
                        }
                    }
                }
            }
            next;
        }

        ####################
        # Other hash nodes #
        ####################
        elsif ( $leaf->{title} =~ $simpleHashKeys
            and not $leaf->{title} eq 'applicationList' )
        {

            # If a `cnodes` key is found, keep old key unchanges
            if ( $leaf->{cnodes} ) {
                $self->newConf->{$name} = $self->refConf->{$name} // {};

            }
            else {
                $subNodes //= [];
                my $count = 0;
                my @old   = (
                    ref( $self->refConf->{$name} )
                    ? ( keys %{ $self->refConf->{$name} } )
                    : ()
                );
                $self->newConf->{$name} = {};
                foreach my $n (@$subNodes) {
                    $self->newConf->{$name}->{ $n->{title} } = $n->{data};
                    $count++;
                    unless ( defined $self->refConf->{$name}->{ $n->{title} } )
                    {
                        $self->confChanged(1);
                        push @{ $self->changes },
                          { key => $name, new => $n->{title}, };
                    }
                    elsif (
                        $self->refConf->{$name}->{ $n->{title} } ne $n->{data} )
                    {
                        $self->confChanged(1);
                        push @{ $self->changes },
                          {
                            key => "$name, $n->{title}",
                            old => $self->refConf->{$name}->{ $n->{title} },
                            new => $n->{data}
                          };
                    }
                    @old = grep { $_ ne $n->{title} } @old;
                }
                if (@old) {
                    $self->confChanged(1);
                    push @{ $self->changes }, { key => $name, old => $_, }
                      foreach (@old);
                }
            }
            next;
        }

        ###############
        # Other nodes #
        ###############

        # Check if subnodes
        my $n = 0;
        if ( ref $subNodesCond ) {
            $subNodesCond = [ grep { $_->{show} } @$subNodesCond ];
            $self->_scanNodes($subNodesCond) or return 0;
            $n++;
        }
        if ( ref $subNodes ) {
            $self->_scanNodes($subNodes) or return 0;
            $n++;
        }
        next if ($n);
        if ( defined $leaf->{data} and ref( $leaf->{data} ) eq 'ARRAY' ) {
            if ( ref( $leaf->{data}->[0] ) eq 'HASH' ) {
                $self->_scanNodes( $leaf->{data} ) or return 0;
            }
            else {
                $self->set( $name, join( ';', @{ $leaf->{data} } ) );
            }
        }

        # Normal leaf
        else {
            $self->set( $name, $leaf->{data} );
        }
    }
    return 1;
}

sub set {
    my $self  = shift;
    my $data  = pop;
    my @confs = ( $self->refConf, $self->newConf );
    my @path;
    while ( @_ > 1 ) {
        my $tmp = shift;
        push @path, $tmp;
        foreach my $i ( 0, 1 ) {
            $confs[$i]->{$tmp} //= {};
            $confs[$i] = $confs[$i]->{$tmp};
        }
    }
    my $target = shift;
    die @path unless ($target);

    # Check new value
    if ( defined $data ) {

        # TODO: remove if $data == default value
        $confs[1]->{$target} = $data;
        eval {
            unless (
                $target eq 'cfgLog'
                or ( defined $confs[0]->{$target}
                    and $confs[0]->{$target} eq $data )
                or (   !defined $confs[0]->{target}
                    and defined $self->defaultValue($target)
                    and $data eq $self->defaultValue($target) )
              )
            {
                $self->confChanged(1);
                push @{ $self->changes },
                  {
                    key => join( ', ', @path, $target ),
                    old => $confs[0]->{$target} // $self->defaultValue($target),
                    new => $confs[1]->{$target}
                  };
            }
        };
    }

    # Set old value if exists
    else {
        if ( exists $confs[0]->{$target} ) {
            $confs[1]->{$target} = $confs[0]->{$target};
        }
    }
}

sub defaultValue {
    my ( $self, $target ) = splice @_;
    die unless ($target);
    my $res = eval {
        &Lemonldap::NG::Manager::Attributes::attributes()->{$target}
          ->{'default'};
    };
    return $res;
}

sub testNewConf {
    my $self = shift;
    return $self->_unitTest( $self->newConf, '' ) and $self->_globalTest();
}

sub _unitTest {
    my ( $self, $conf ) = splice @_;
    my $types = &Lemonldap::NG::Manager::Attributes::types();
    my $attrs = &Lemonldap::NG::Manager::Attributes::attributes();
    my $res   = 1;
    foreach my $key ( keys %$conf ) {
        my ( $attr, $type );

        # Check if key exists
        unless ( $attr = $attrs->{$key} ) {
            push $self->errors, { message => "__unknownKey__: $key" };
            next;
        }
        if ( $key =~ $simpleHashKeys ) {

            #TODO
        }
        elsif ( defined $attr->{keyTest} ) {

            #TODO
        }
        else {
            die "Unkown type $attr->{type}"
              unless ( $type = $types->{ $attr->{type} } );
            my $test = $attr->{test}    // $type->{test};
            my $msg  = $attr->{msgFail} // $type->{msgFail};
            if ( my $ref = ref($test) ) {
                if ( $ref eq 'CODE' ) {
                    my ( $r, $w ) = $test->( $conf->{$key}, $conf, $attr );
                    unless ($r) {
                        push $self->errors,
                          { message => "$key: " . ( $w ? $w : $msg ) };
                        $res = 0;
                    }
                    elsif ($w) {
                        push $self->warnings, { message => "$key: $w" };
                    }
                }
                elsif ( $ref eq 'Regexp' ) {
                    die "msgFail undefined for type \"$attr->{type}\""
                      unless ( defined $msg );
                    unless ( $conf->{$key} =~ $test ) {
                        push $self->errors,
                          { message => "$key: $msg ($conf->{$key})" };
                    }
                }
                else {
                    die
"Malformed test: only regexp ref or sub are accepted (type \"$ref\")";
                }
            }
            else {
                die
"Malformed test: only regexp ref or sub are accepted (\"$test\")";
            }
        }
    }
    return $res;
}

sub _globalTest {
    my $self = shift;
    require Lemonldap::NG::Manager::Conf::Tests;
    my $result = 1;
    my $tests  = &Lemonldap::NG::Manager::Conf::Tests::tests( $self->newConf );
    while ( my ( $name, $sub ) = each %$tests ) {
        my ( $res, $msg );
        eval {
            ( $res, $msg ) = $sub->();
            if ( $res == -1 ) {
                push $self->needConfirm, { message => $msg };
            }
            elsif ($res) {
                if ($msg) {
                    push $self->warnings, { message => $msg };
                }
            }
            else {
                $result = 0;
                push $self->errors, { message => $msg };
            }
        };
        if ($@) {
            push $self->warnings, "Test $name failed: $@";
            $self->lmLog( "Test $name failed: $@", 'error' );
        }
    }
    return $result;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Manager::ConfParser - Perl extension for parsing new uploaded
configurations.

=head1 SYNOPSIS

  require Lemonldap::NG::Manager::ConfParser;
  my $parser = Lemonldap::NG::Manager::ConfParser->new(
      { tree => $new, refConf => $self->currentConf }
  );
  my $res = { result => $parser->check };
  $res->{message} = $parser->{message};
  foreach my $t (qw(errors warnings changes)) {
      push @{ $res->{details} }, { message => $t, items => $parser->$t }
        if ( @{$parser->$t} );
  }

=head1 DESCRIPTION

Lemonldap::NG::Manager::ConfParser checks new configuration

This package is used by Manager to examine uploaded configuration. It is
currently called using check() which return a boolean.
check() looks if a newConf is available. If not, it builds it from uploaded
JSON (using scanTree() subroutine)

Messages are stored in errors(), warnings() and changes() as arrays.

This interface uses L<Plack> to be compatible with CGI, FastCGI,...

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<http://lemonldap-ng.org/>

=head1 AUTHORS

=over

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2015 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

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
