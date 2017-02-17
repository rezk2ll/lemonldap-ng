package Lemonldap::NG::Portal::Lib::OtherSessions;

use strict;
use Mouse;

our $VERSION = '2.0.0';

has module =>
  ( is => 'rw', default => 'Lemonldap::NG::Common::Apache::Session' );

has moduleOpts => (
    is      => 'rw',
    default => sub {
        my %opts = %{ $_[0]->{conf}->{globalStorageOptions} || {} };
        $opts{backend} = $_[0]->{conf}->{globalStorage};
        return \%opts;
    }
);

# Build an HTML array to display sessions
# @param $sessions Array ref of hash ref containing sessions datas
# @param $title Title of the array
# @param $displayUser To display "User" column
# @param $displaError To display "Error" column
# @return HTML string
sub mkSessionArray {
    my ( $self, $sessions, $title, $displayUser, $displayError ) = @_;

    return "" unless ( ref $sessions eq "ARRAY" and @$sessions );

    my $tmp = $title ? qq'<h3 trspan="$title"></h3>' : "";
    $tmp .= "<table class=\"info\"><tbody>";

    $tmp .= "<tr>";
    $tmp .= '<th trspan="user"></th>'
      if ($displayUser);
    $tmp .= '<th trspan="date"></th>';
    $tmp .= '<th trspan="ipAddr"></th>';
    $tmp .= "<th>" . $self->{sessionDataToRemember}->{$_} . "</th>"
      foreach ( keys %{ $self->{sessionDataToRemember} } );
    $tmp .= '<th trspan="errorMsg"></th>'
      if ($displayError);
    $tmp .= '</tr>';

    foreach my $session (@$sessions) {
        $tmp .= "<tr>";
        $tmp .= "<td>$session->{user}</td>" if ($displayUser);
        $tmp .=
"<td><script type=\"text/javascript\">var _date=new Date($session->{_utime}*1000);document.write(_date.toLocaleString());</script></td>";
        $tmp .= "<td>$session->{ipAddr}</td>";
        $tmp .= "<td>" . ( $session->{$_} || "" ) . "</td>"
          foreach ( keys %{ $self->{sessionDataToRemember} } );
        $tmp .= "<td>$session->{error}</td>" if ($displayError);
        $tmp .= "</tr>";
    }
    $tmp .= '</tbody></table>';
    return $tmp;
}

1;
