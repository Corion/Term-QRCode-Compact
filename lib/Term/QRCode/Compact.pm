package Term::QRCode::Compact;
use 5.020;
use feature 'signatures';
no warnings 'experimental::signatures';
use utf8;

use Exporter 'import';
use Imager::QRCode;

our @EXPORT_OK = ('qr_code_as_text');

our $VERSION;

our %charset = (
    ascii_1x1 => {
		xfactor => 1,
		yfactor => 1,
		charset => [ ' ', '*' ],
	},
    ascii_2x1 => {
		xfactor => 1,
		yfactor => 1,
		charset => [ '  ', '##' ],
	},
    utf8_1x2 => {
		xfactor => 1,
		yfactor => 2,
		charset => [ ' ', '▀' ,
					 '▄', '█' ],
	},
);

sub compress_lines( $lines, $xfactor, $yfactor, $charset ) {
    my $res;
    
    my $yofs = 0;
    
    while( $yofs < @$lines ) {
        my $xofs = 0;
		my $cols = @{$lines->[$yofs]};
        while ($xofs < $cols) {
            my $bits = 0;
            for my $l (0..$yfactor-1) {
                for my $c (0..$xfactor-1) {
                    my $bitpos = $l*$xfactor + $c;
					#say sprintf '%02d x %02d %04b %d %04b', $xofs+$c, $yofs+$l, $bitpos, $lines->[$yofs+$l]->[$xofs+$c], $bits;
					
                    $bits += $lines->[$yofs+$l]->[$xofs+$c] << $bitpos;
                }
            }
            $res .= $charset->[ $bits ];
            $xofs += $xfactor
        };
        $yofs += $yfactor;
        $res .= "\n";
    }
    
    return $res
}

sub qr_code_as_text( %options ) {
	$options{charset} //= 'utf8_1x2';

    my $qrcode = Imager::QRCode->new(
        size          => 2,
        margin        => 2,
        version       => 1,
        level         => 'M',
        casesensitive => 1,
        lightcolor    => Imager::Color->new(255, 255, 255),
        darkcolor     => Imager::Color->new(0, 0, 0),
    );
	
	my $charset = $charset{ $options{ charset }};
    
    my $img = $qrcode->plot($options{text});
    my $rows = $img->getheight;
    my $cols = $img->getwidth;
    my $res;
    my @lines;
    for my $row (0..$rows-1) {
        my $line = [];
        for my $col (0..$cols-1) {
            my $val = $img->getpixel( 'x' => $col, 'y' => $row );
            my $is_black = [$val->rgba]->[0] == 0 ? 1 : 0;
            push @$line, $is_black;
        }
        push @lines, $line;
        
    }
    #$res = compress_lines( \@lines, 1, 1, $charset_ascii_1x1 );
    #$res = compress_lines( \@lines, 1, 1, $charset_ascii_2x1 );
    return compress_lines( \@lines,
	    $charset->{xfactor},
		$charset->{yfactor},
		$charset->{charset},
	);
}

1;

=head1 SEE ALSO

L<Text::QRCode> - needs an update to support C<.> in C<@INC>

L<Term::QRCode> - needs L<Text::QRCode>

=cut