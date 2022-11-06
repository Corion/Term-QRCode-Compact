#!perl
use 5.020;
use feature 'signatures';
no warnings 'experimental::signatures';
use utf8;

use Term::QRCode::Compact 'qr_code_as_text';
use Getopt::Long;

GetOptions(
    'charset|c=s' => \my $charset,
);

$charset //= 'utf8';

if( $^O eq 'MSWin32' ) {
    require Win32::Console;
    Win32::Console::OutputCP(65001);
}

binmode STDOUT, ':encoding(UTF-8)';

print qr_code_as_text(
      text => $ARGV[0]
    , charset => $charset
);

=head1 SEE ALSO

L<Text::QRCode> - needs an update to support C<.> in C<@INC>

L<Term::QRCode> - needs L<Text::QRCode>

=cut