#!perl -w

use strict;
use warnings;
use Date::Manip;
use LWP::UserAgent;

my $err = 0;
my $dec = 0;

Date_Init( 'TZ=PDT' );
my $end_date = ParseDate('today 0:00:00');

my $stock = uc $ARGV[0];
if ( !$stock ) { print "symbol: "; $stock = uc <STDIN>; chomp $stock }

use constant DEFAULT_DAYS => 128;
my $days = $ARGV[1] ? $ARGV[1] : DEFAULT_DAYS;
use constant BUSINESS_DAY_CONVERSION => ( 7 / 4.6 );
$days = int( $days * BUSINESS_DAY_CONVERSION )
  ;    # business days calc doesn't work - needs config file
my $start_date = DateCalc( $end_date, "- $days days", \$err, 0 ); # use adj days
$days = int(
    Delta_Format( DateCalc( $start_date, $end_date, \$err ),, $dec, ('%dt') ) );

#my $start_date = DateCalc($end_date,"- $days business days",\$err,2); # business days
#$days = int(Delta_Format(DateCalc($start_date,$end_date,\$err),,$dec, ('%dt')));

print "$stock\n$start_date\n$end_date\ndays=$days";

my $stock_csv_hist_url = 'http://table.finance.yahoo.com/table.csv?s=';
$stock_csv_hist_url .= $stock;
my ( $m, $d, $Y ) = UnixDate( $start_date, "%m", "%d", "%Y" );
$stock_csv_hist_url .= sprintf( "&a=%s&b=%s&c=%s", $m - 1, $d, $Y );
( $m, $d, $Y ) = UnixDate( $end_date, "%m", "%d", "%Y" );
$stock_csv_hist_url .= sprintf( "&d=%s&e=%s&f=%s&g=d", $m - 1, $d, $Y );

#$stock_csv_hist_url = "http://table.finance.yahoo.com/table.csv?s=DNA&a=00&b=27&c=2004&d=02&e=27&f=2004&g=d&ignore=.csv";

#print "\n$stock_csv_hist_url\n";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $stock_csv_hist_url );
$req->header( Accept => 'text/html' );

# send request to server and get response back
my $res = $ua->request($req);

# print $res->content;

# check the outcome
my $file = 'table.tsv';
my $price;
my @lines;
use constant CLOSING => 4;
if ( $res->is_success ) {
    @lines = split /\n/msx, $res->content;
    $lines[0] = '# ' . $lines[0];
    if ( $#lines > 0 ) { $price = ( split /,/msx, $lines[1] )[CLOSING] }
    open my $txt, '>', $file or die "can't open $file\n";
    foreach (@lines) {
        s/,/\t/msxg;
        print { $txt } "$_\n";
    }
    close $txt or die "can't close $file\n";
}
print "  lines=$#lines  (err:$err)\n$price";
print "\nfinished\n";

exit;
