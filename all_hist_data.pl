#!perl -w

my $fn =  $ARGV[0]; 
if (!$fn) {print "filename: ";$fn = <STDIN>; chomp $fn}

my $days = $ARGV[1] ? $ARGV[1] : 68; chomp $days;

open (SYM, "<$fn") or die ("can't open $fn\n");
my @syms = <SYM>;
close(SYM);

foreach  (@syms) {
	($sym) = split(/,/);

# my $out = `perl stock_get_data.pl $sym $days`;
my $out =  `perl stock_get_data_google.pl $sym $days`;
my @out = split(/\s+/,$out);
print "$sym,$out[3],$out[4], ";

if($out[4] ne "lines=-1") {
$out = `perl linear-stock.pl -q $days`;
@out = split(/\s+/,$out);
print join(", ",@out);
print "\n";
} else {
print "ERROR\n";
}
}
sleep 10;

exit;
