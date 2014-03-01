#!Perl -w

  use strict;
  use Math::FFT;
  
  my $PI = 3.1415926539;
  my $N = $ARGV[0] ? $ARGV[0] : 64;
  my $n = 2;
  while ($n < $N+1) { $n <<= 1 }
  $N = $n >> 1;
  my $K = $N/8;

  # print "\n$PI  $N $K \n";

  open(IN,"<table.tsv");
  my $in = <IN>;

  my ($series, $other_series);
  for (my $k=$N-1; $k>=0; --$k) {
      $in = <IN>; chomp $in;
      $series->[$k] = (split("\t",$in))[4];
  }
  close IN;

  #  for (my $k=0; $k<$N; $k++) { print  "$k - $series->[$k]\n";  }

  my $fft = new Math::FFT($series);
  my $coeff = $fft->rdft();
  # my $spectrum = $fft->spctrm(window => 'hann', overlap => 0) ;
  my $spectrum = $fft->spctrm() ;

  my $reverse_coeff;
  for (my $k=0; $k<$N; $k++) {
	$reverse_coeff->{abs($coeff->[$k])} = $k ;
  }
  
  sub num {$a <=> $b;}
  my ($k, $x, $other_coeff);
  foreach $x (reverse sort num keys %$reverse_coeff) {
	  $k++;
#	  print "$k -> $x , $reverse_coeff->{$x} \n"; 
	  if ($k <= $K) {
		$other_coeff->[$reverse_coeff->{$x}]=$coeff->[$reverse_coeff->{$x}]
	  } else {
		$other_coeff->[$reverse_coeff->{$x}] = 0;
	  }
  }
  #  $N = 128;
  #  $other_coeff->[$N-1] = 0;
  #  $K =  6;
  for ($k=1; $k<$N; $k++) { 
  #	      $other_coeff->[$k] = 0 unless $K == $k
  }
  $other_series = $fft->invrdft($other_coeff); 
  #  for ($k=0; $k<$N; $k=$k+1) { $other_series->[$k] = 0; }
  my $other_fft = new Math::FFT($other_series);
  my $other_spectrum = $other_fft->spctrm(window => 'hann');
  # my $other_spectrum = $other_fft->spctrm();
  my $correlation = $fft->correl($other_fft);

  open(OUT, ">table_fft.tsv");
  my $header = join("\t",qw(n data spectrum coeff other o_spec o_coeff correlation));
	  print OUT "#",$header,"\n";
  for (my $k=0; $k<$N; $k++) {
      print OUT 
      	$k,"\t",
      #      print OUT "$rev_co[$k]\t";
      	$series->[$k],"\t",
      	$spectrum->[$k] || 0,"\t",
        $coeff->[$k],"\t",
	$other_series->[$k],"\t",
	$other_spectrum->[$k] || 0,"\t",
	$other_coeff->[$k],"\t",
	$correlation->[$k] || 0,"\t",
      	"\n";
  }
  close OUT;
