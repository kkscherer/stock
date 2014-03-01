#!/usr/bin/perl -w
# This is not a CGI, so taint mode not required

use strict;

use File::Find;
use Getopt::Long;
#require "stem.pl";
use Tie::DBI;

use constant DB_CACHE      => 0;
use constant DEFAULT_INDEX => "/usr/local/apache/data/index.db";

my( %opts, %index, @files, $stop_words );

GetOptions( \%opts, "dir=s",
                    "cache=s",
                    "index=s",
                    "ignore",
                    "stop=s",
                    "numbers",
                    "stem"
	    );

die usage(  ) unless $opts{dir} && -d $opts{dir};

$opts{'index'}        ||= DEFAULT_INDEX;
#$DB_BTREE->{cachesize}  = $cache || DB_CACHE;

$index{"!OPTION:stem"} = 1 if $opts{'stem'};
$index{"!OPTION:ignore"} = 1 if $opts{'ignore'};

  tie %index,'Tie::DBI','mysql:test:slug;user=scherer;password=kks','test','id',{CLOBBER=>2,DEBUG=>0}
    or die "Cannot tie database: $!\n";
#  tie %index,'Tie::DBI',
#	 	   table    => 'test',
#                   key      => 'id',
#                   user     => 'scherer',
#                   password => 'kks',
#                   CLOBBER  => 2};

print STDERR "tied <<<",tied(%index)->fields, ">>>\n";

find( sub { push @files, $File::Find::name }, $opts{dir} );
$stop_words = load_stopwords( $opts{stop} ) if $opts{stop};

process_files( \%index, \@files, \%opts, $stop_words );

untie %index;


sub load_stopwords {
    my $file = shift;
    my $words = {};
    local (*INFO, $_);
    
    die "Cannot file stop file: $file\n" unless -e $file;
    
    open INFO, $file or die "$!\n";
    while ( <INFO> ) {
        next if /^#/;
        $words->{lc $1} = 1 if /(\S+)/;
    }
    
    close INFO;    
    return $words;
}

sub process_files {
    my( $index, $files, $opts, $stop_words ) = @_;
    local (*FILE, $_);
    local $/ = "\n\n";
    
    for ( my $file_id = 0; $file_id < @$files; $file_id++ ) {
        my $file = $files[$file_id];
        my %seen_in_file;
        
        next unless -T $file;
        
        print STDERR "Indexing $file (id=$file_id)\n";
		$index{"!FILE_NAME:$file_id"} = {'value' => $file};
# 		$index{"kks"} = "hello";
      
        open FILE, $file or die "Cannot open file: $file!\n";
        
        while ( <FILE> ) {
            
            tr/A-Z/a-z/ if $opts{ignore};
            s/<.+?>//gs; # Woa! what about < or > in comments or js??
            
            while ( /([a-z\d]{2,})\b/gi ) {
                my $word = $1;
                next if $stop_words->{lc $word};
                next if $word =~ /^\d+$/ && not $opts{number};
                
                ( $word ) = stem( $word ) if $opts{stem};
                
               $index{$word} = {'value'=> ( exists $index{$word}->{'value'} ? 
                    $index{$word}->{'value'}.":" : "" ) . $file_id} unless 
                    $seen_in_file{$word}++;
#		my $prevword = $index{$word}->{value}; 
#		print STDERR "$prevword, $word\n";
#		$index{$word} = {'value'=> "$prevword:$file_id"} 
#			unless $seen_in_file{$word}++;
            }
        }
    }
}

sub usage {
    my $usage = <<End_of_Usage;

Usage: $0 -dir directory [options]

The options are:

  -cache         DB_File cache size (in bytes)
  -index         Path to index, default:/usr/local/apache/data/index.db
  -ignore        Case-insensitive index
  -stop          Path to stopwords file
  -numbers       Include numbers in index
  -stem          Stem words

End_of_Usage
    return $usage;
}

