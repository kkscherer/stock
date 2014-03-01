#!perl # -w
# $Id: stock_hist_plot.pl 221 2011-10-21 21:49:52Z  $:

my $gnuplot = '"C:\\Program Files\\gnuplot\\bin\\wgnuplot.exe"';

my $sym = $ARGV[0];
if ( !$sym ) { print "symbol: "; $sym = <STDIN>; chomp $sym }
my $days = $ARGV[1] ? $ARGV[1] : 128;

# print `perl stock_get_data.pl $sym $days`;
my $status = `perl stock_get_data.pl $sym $days`;
print $status;
my @lines = split( /\s+/, $status );
open( plt, ">title.plt" ) || die("can't write to title.plt");
print plt 'set title "', uc( $lines[0] ), " - $lines[1] - $lines[2]\"";
close plt;

print `perl linear-stock.pl -q $days`;
system("$gnuplot title.plt stock_lin.plt -q");

if ($fft) { exit }

print `perl fft-stock.pl $days`;
exec("$gnuplot stock_fft.plt -q");

print "\nfinished\n";

exit;
