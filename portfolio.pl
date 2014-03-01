#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::UserAgent;

my $stock_csv_url = 'http://finance.yahoo.com/d/quotes.csv?s=&f=sl1pn' ;

#$stock_csv_hist_url = "http://table.finance.yahoo.com/table.csv?s=DNA&a=00&b=27&c=2004&d=02&e=27&f=2004&g=d&ignore=.csv";

#print "\n$stock_csv_url\n";

my $file = 'portfolio.csv';
my $syms;
my @lines;
my @fields;
open my $txt, '<', $file or die "can't open $file\n";
while (<$txt>) {
	chop;
	push(@lines,$_);
        @fields = split(/,/);
	$syms .= $fields[0] . ",";
}
close $txt or die "can't close $file\n";
$syms =~ s/"//g;
$syms =~ s/\,$//g;
chomp($syms);

print STDERR "  lines=$#lines \n";
$stock_csv_url =~ s/s=&f/s=$syms&f/;
print STDERR "$stock_csv_url \n";
#print "\nfinished\n";



my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $stock_csv_url );
$req->header( Accept => 'text/html' );

# send request to server and get response back
my $res = $ua->request($req);
my @reslines;
my $line;
my $price="";
my $nr=0;
my %xml;
use constant CLOSING => 2;
use constant LAST => 1;
if ( $res->is_success ) {
	@reslines = split /\r/msx, $res->content;
	foreach $line (@reslines) {
		if (length($line) <= 1) {next}
       		$price = ( split /,/msx, $line )[LAST];
       		$syms = ( split /,/msx, $line )[0];
		$xml{$syms} = $price;
		$lines[$nr] .= $price.",";
	        print "$lines[$nr]\n";
		$nr++;
	}
} 
print STDERR "  lines=$#reslines\n";

print %xml,"\n";

#print $res->content;

exit
