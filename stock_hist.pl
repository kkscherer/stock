#!perl # -W

foreach (qw(DNA INTC ELN TLM VLO GLD ADBE ^IXIC ^DJI)) {
	print "$_\n";
	`perl stock_hist_data.pl $_ -f`;
}
exit;

