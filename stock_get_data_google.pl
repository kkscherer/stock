#!perl -w

use Date::Manip;
use LWP::UserAgent;

&Date_Init( "TZ=PDT", "GlobalCnf=C:/Perl/site/lib/manip.cnf" );

my $err = 0;
my $dec = 0;

my $stock = $ARGV[0];
if ( !$stock ) { print "symbol: "; $stock = <STDIN>; chomp $stock }
my $days = $ARGV[1] ? $ARGV[1] : 128;

my $end_date = ParseDate("today 0:00:00");

$days =
  int( $days * 7.4 / 5 );  # business days calc doesn't work - needs config file
my $start_date = DateCalc( $end_date, "- $days days", \$err, 0 ); # use adj days
$days = int(
    Delta_Format( DateCalc( $start_date, $end_date, \$err ),, $dec, ('%dt') ) );

#my $start_date = DateCalc($end_date,"- $days business days",\$err,2); # business days
#$days = int(Delta_Format(DateCalc($start_date,$end_date,\$err),,$dec, ('%dt')));

print "$stock\n$start_date\n$end_date\ndays=$days";

$stock_csv_hist_url = "http://www.google.com/finance/historical?q=";
$stock_csv_hist_url .= $stock;
$stock_csv_hist_url .= "&startdate=" . UnixDate( $start_date, "%Q" );
$stock_csv_hist_url .= "&enddate=" . UnixDate( $end_date, "%Q" );
$stock_csv_hist_url .= "&histperiod=daily&output=csv";

# http://www.google.com/finance/historical?q=EGHT&startdate=20101229&enddate=20111017&histperiod=daily
#$stock_csv_hist_url =~ s/^(.*q=).*(&hist.*)$/$1$stock$2/;
#$stock_csv_hist_url = "http://table.finance.yahoo.com/table.csv?s=DNA&a=00&b=27&c=2004&d=02&e=27&f=2004&g=d&ignore=.csv";

# print "\n$stock_csv_hist_url\n";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $stock_csv_hist_url );
$req->header( Accept => 'text/html' );

# send request to server and get response back
my $res = $ua->request($req);

# print $res->content;

# check the outcome
my $file = "table.tsv";
if ( $res->is_success ) {
    @lines = split( /\n/, $res->content );
    $lines[0] = "# " . $lines[0];
    $price = ( split( /,/, $lines[1] ) )[4];
    open( TXT, ">$file" ) or die "can't open $file\n";
    foreach (@lines) {
        s/,/\t/g;
        print TXT "$_\n";
    }
}
print "  lines=$#lines  (err:$err)\n", $price;

print "\nfinished\n";

exit;
