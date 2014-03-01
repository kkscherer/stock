#!perl -w
use strict;

my $fn = $ARGV[0];
if ( !$fn ) { print "symbol file: "; $fn = <STDIN>; chomp $fn }

my $days = $ARGV[1] ? $ARGV[1] : 68;
chomp $days;

open( SYM, "<$fn" ) or die("can't open $fn\n");
my @syms = <SYM>;
close(SYM);

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
my $date = sprintf "%4d-%02d-%02d\n", $year + 1900, $mon + 1, $mday;

use CGI::Pretty qw(:all);

# print header;
my $style = <<END;
<!-- 
h1,h2,h3,h4,h5,h6,th,td
{
color:blue
}
td.red {color:red}
td.green {color:green}
td.black {color:black}
-->
END

print start_html(
    -title  => "Stock data $fn",
    -author => 'scherer@hotmail.com',
    -base   => 'true',
    -target => '_blank',
    -meta   => {
        'keywords'  => 'pharaoh secret mummy',
        'copyright' => 'copyright 2009 kks'
    },
    -style   => { 'code' => $style },
    -BGCOLOR => 'white'
  ),
  h1("Stock data for $fn on $date"), br;

my @headings = ( 'Symbol', 'N', 'll', 'l', 'current', 'h', 'hh', 'gain' );

my @rows = th( \@headings );

foreach (@syms) {
    ( my $sym ) = split(/,/);

    my $out   = `perl stock_get_data.pl $sym $days`;
    my @out   = split( /\s+/, $out );
    my @lines = split( /=/, $out[4] );

    # print "$sym lines @lines \n";

    if ( $lines[1] >= $days ) {
        my $out2 = `perl linear-stock.pl -q $days`;
        my ($l, $ll, $hh, $h, $pc) = split( /\s+/, $out2 );

        # print "out2 @out2 \n";

        my $color;
        if    ( $out[6] < $l ) { $color = "red" }
        elsif ( $out[6] > $h) { $color = "green" }
        else                         { $color = "black" }

        my $row =
            td( { -class => "black" }, [ $sym, $days ] )
          . td( [ $ll,$l ] )
          . td( { -class => $color }, [ $out[6] ] )
          . td( [ $h, $hh, $pc ] );
        push( @rows, $row );

    }
    else {
        push( @rows, td( ['ERROR'] ) );

    }
}
print table( { -border => undef, -width => '25%' }, Tr( \@rows ) );

print end_html;

exit;
