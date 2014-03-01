#!Perl -w
#
# $Id: linear-stock.pl 221 2011-10-21 21:49:52Z  $

use strict;
use Date::Manip;
use Statistics::LineFit;
use Data::Dump qw(dump);
#&Date_Init("setdate","PDT");
my $datum = new Date::Manip::Date [ "setdate", "now,US/Pacific" ];

$ARGV[0] = "" unless $ARGV[0];
$ARGV[1] = "" unless $ARGV[1];

# Number of records to read
my $N = $ARGV[1] || 128;
my ( $k, $in, $header );
my ( $series, $other_series );
my ( $date, $open, $high, $low, $close, $vol, $numdate, $x );

# read data sets
open( IN, "<", 'table.tsv' ) or die("$!\n");
$header = <IN>;
chomp $header;
$header =~
  s/\tAdj Close//;  # fix header (and date) - should be done in get data routine
$header =~ s/.*Date\t/# Date\t/;
$header .= "\t";
for ( my $k = $N - 1 ; $k >= 0 ; --$k ) {
    $in = <IN>;
    chomp $in;
    (
        $date->[$k], $open->[$k],  $high->[$k],
        $low->[$k],  $close->[$k], $vol->[$k]
    ) = split( "\t", $in );
    $x->[$k] = $k;
    $numdate->[$k] = &UnixDate( &ParseDate( $date->[$k] ), "%s" );
    $date->[$k] = &UnixDate( &ParseDate( $date->[$k] ), "%d-%h-%y" ); # fix date
}
close IN;

#print dump($x, $numdate),"\n";

# calculate linear regression parameters
my ( $data, $linefit );

$linefit = Statistics::LineFit->new();

foreach $data ( $low, $close, $high, $vol ) {
    next
      unless $linefit->setData( $numdate, $data )
          or die "Invalid regression data\n";
    ( $data->[$N], $data->[ $N + 1 ] ) = $linefit->coefficients();
    $data->[ $N + 2 ] = $linefit->rSquared();
    $data->[ $N + 3 ] = [ $linefit->residuals() ];

    if ( defined $data->[$N] && $ARGV[0] ne "-q" ) {
        print "Slope: $data->[$N+1]  Y-intercept: $data->[$N]\n ",
          "error: $data->[$N+2]", $numdate->[ $N - 1 ], " ",
          $numdate->[ $N - 1 ] * $data->[ $N + 1 ] + $data->[$N], "\n";
    }
}
$data = $low;
my ( $llimit1, $llimit2 );
$data->[$N] = shift_line( $data, $numdate, "down", 7 );
if ( defined $data->[$N] && $ARGV[0] ne "-q" ) {
    print "Low Slope: $data->[$N+1]  Y-intercept: $data->[$N]\n",
      "error: $data->[$N+2] $numdate->[ $N - 1 ] \n",
      ;
}
if ( defined $data->[$N] ) {
    $llimit1 = $numdate->[ $N - 1 ] * $data->[ $N + 1 ] + $data->[$N];
    $llimit2 =
      ( $numdate->[ $N - 1 ] + ( 30 * 24 * 60 * 60 ) ) * $data->[ $N + 1 ] +
      $data->[$N];
    print int( $llimit1 * 100 ) / 100, "  ", int( $llimit2 * 100 ) / 100, "\n";
}

$data = $high;
$data->[$N] = shift_line( $data, $numdate, "up", 14 );
if ( defined $data->[$N] && $ARGV[0] ne "-q" ) {
    print "High Slope: $data->[$N+1]  Y-intercept: $data->[$N]\n",
      "error: $data->[$N+2] $numdate->[ $N - 1 ] \n",
      ;
}
if ( defined $data->[$N] ) {
    my $ulimit1 = $numdate->[ $N - 1 ] * $data->[ $N + 1 ] + $data->[$N];
    my $ulimit2 =
      ( $numdate->[ $N - 1 ] + ( 30 * 24 * 60 * 60 ) ) * $data->[ $N + 1 ] +
      $data->[$N];
    print int( $ulimit1 * 100 ) / 100, "  ", int( $ulimit2 * 100 ) / 100, "\n";
    print int( ( $ulimit1 - $llimit1 ) / $llimit1 * 100 ), "%\n";
}

# calculate new data

my ( $low_lim, $close_lim, $high_lim, $vol_lim );

for ( my $k = 0 ; $k < $N ; $k++ ) {
    $low_lim->[$k] =
      int( ( $numdate->[$k] * $low->[ $N + 1 ] + $low->[$N] ) * 100 ) / 100;
    $close_lim->[$k] =
      int( ( $numdate->[$k] * $close->[ $N + 1 ] + $close->[$N] ) * 100 ) / 100;
    $high_lim->[$k] =
      int( ( $numdate->[$k] * $high->[ $N + 1 ] + $high->[$N] ) * 100 ) / 100;
    $vol_lim->[$k] =
      int( ( $numdate->[$k] * $vol->[ $N + 1 ] + $vol->[$N] ) * 100 ) / 100;
}

# write out old/new data

open( OUT, ">table_lin.tsv" ) or die("Could not write to file - $!\n");
$header .= "\tLow_Lim\tClose_Lim\tHigh_Lim\tVol_Lim\tepoch";
print OUT "$header\n";
for ( my $k = 0 ; $k < $N ; $k++ ) {
    print OUT join( "\t",
        $date->[$k],            $open->[$k],    $high->[$k],
        $low->[$k],             $close->[$k],   $vol->[$k],
        $low->[ $N + 3 ]->[$k], $low_lim->[$k], $close_lim->[$k],
        $high_lim->[$k],        $vol_lim->[$k], $numdate->[$k] ),
      "\n";
}
if (0) {
    for ( my $k = $N ; $k < $N + 3 ; $k++ ) {
        print OUT join( "\t",
            '', '', $high->[$k], $low->[$k], $close->[$k], $vol->[$k] ),
          "\n";
    }
}
if (0) {
    for ( $k = $N + 3 ) {
        print OUT join( "\t",
            '', '', $high->[$k], $low->[$k], $$close->[$k], ${$vol}->[$k] ),
          "\n";
    }
}
close OUT;

exit;

sub shift_line    # (\$\$)
{
    my ( $y, $x, $dir, $N0 ) = @_;
    my ( %res, @res, @ys, @xs, @keys );
    my ( $key, $k, $intercept, $slope, $n, $p0, $y0, $x0, $y1, $x1 );
    my ( $yn, $xs, $ys, $p );
    my $Nt      = $N;
    my $linefit = Statistics::LineFit->new();

    #print "y\n",dump($y);
    #print "x\n",dump($x);
    # residual/x hash
    for ( my $k = 0 ; $k < $N ; $k++ ) {
        $res{ $y->[ $N + 3 ]->[$k] } = $k;
    }

    #print "res\n",dump(%res),"\n";
    #pick N0 x/y pairs with top/bottom residuals
    @keys = sort { $a <=> $b } keys %res;
    if ( $dir eq "up" ) { @keys = reverse @keys }

    #print "keys\n",dump(@keys),"\n";
    $n = 0;
    foreach $key (@keys) {
        if ( $n < $N0 ) {
            $xs->[$n] = $x->[ $res{$key} ];
            $ys->[$n] = $y->[ $res{$key} ];
            $n++;
        }
        else {
            last;
        }
    }

    #print "ys\n",dump($ys),"\n";
    #print "xs\n",dump($xs),"\n";
    #fit new curve thru top/bottom x/y pairs
    $N = $N0;
    $linefit->setData( $xs, $ys ) or die "Invalid regression data\n";
    ( $intercept, $slope ) = $linefit->coefficients();
    @res = $linefit->residuals();
    $N   = $Nt;

    # print dump( @res, $xs, $ys);
    # select point with smallest residual
    $p  = abs( $res[0] );
    $x1 = $xs->[0];
    $y1 = $ys->[0];
    for ( $k = 0 ; $k < $N0 ; $k++ ) {
        if ( $p < abs( $res[$k] ) ) {
            $p  = abs( $res[$k] );
            $x1 = $xs->[$k];
            $y1 = $ys->[$k];
        }
    }

    #calc intercept of line thru this point with slope of original line.
    #print "$x1 $y1 $yn\n$slope $intercept\n$y->[ $N + 1 ] $y->[$N]\n";
    return ( $y1 - $y->[ $N + 1 ] * $x1 );
}
