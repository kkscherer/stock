use Text::CSV_XS;

my $file = "../../downloads/Time Sheet.csv";
my @rows;
my $csv = Text::CSV_XS->new ({ binary => 1, eol => undef  }) or
    die "Cannot use CSV: ".Text::CSV->error_diag ();
open my $fh, "<:encoding(utf8)", $file or die "$file: $!";

my $old_day, $day, $hour, $old_hour;
while (my $row = $csv->getline ($fh)) {
	$old = $day; 
       $day = $row->[1];
	$day =~ s/(\d+\/\d+\d+) .*/$1/;
	if ($day !~ $old) {
		$hour = $row->[2];
    	} else {
		$hour += $row->[2];
		$row = pop @rows;
#		$row->[1] .= "=====";	push @rows, $row;
    	}
    	push @rows, [$day,$hour];
}
$csv->eof or $csv->error_diag ();
close $fh;

$csv->eol ("\n");
open $fh, ">:encoding(utf8)", "new.csv" or die "new.csv: $!";
$csv->print ($fh, $_) for @rows;
close $fh or die "new.csv: $!";

exit;
