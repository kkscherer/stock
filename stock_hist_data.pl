#!perl -W
# $Id: stock_hist_data.pl 220 2011-10-19 06:12:12Z  $:

my $gnuplot = '"C:\\Program Files\\gnuplot\\bin\\wgnuplot.exe"';

my $sym = $ARGV[0];
if ( !$sym ) { print "symbol: "; $sym = <STDIN>; chomp $sym }
my $days = $ARGV[1] ? $ARGV[1] : 128;

#print `perl stock_get_data.pl $sym 128`;
print `perl stock_get_data_google.pl $sym $days`;

print `perl linear-stock.pl -q $days`;

print "\nfinished\n";

sleep 2;

exit;
