#!perl -w
use strict;
use Date::Manip;

my $dates = new Date::Manip::Date;


my $today=DateCalc( "today" , "+ 0 business day" );
my $date=DateCalc( "today" , "- 65 business day" );
my $todays = $dates->parse_date("today");

my $delta = DateCalc($today,$date);
my @da = Delta_Format($delta,"%wv %dv");
print "\n=$today\n $date\n $delta\n ",@da, 7*$da[0]+$da[1];

$delta = DateCalc(DateCalc( "today" , "- 65 business day" ),"today");
my $das = 7*Delta_Format($delta,"%wv") + Delta_Format($delta,"%dv");
print "\n$delta\n$das\n";

exit;

my $fn =  $ARGV[0]; 
if (!$fn) {print "symbol file: ";$fn = <STDIN>; chomp $fn}

my $days = $ARGV[1] ? $ARGV[1] : 93; chomp $days;

exit;
