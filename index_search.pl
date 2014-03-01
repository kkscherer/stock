#!/usr/bin/perl -wT

# use DB_File;
use Tie::DBI;
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use File::Basename;
# require stem.pl;

use strict;

use constant INDEX_DB => "/usr/local/apache/data/index.db";

my( %index, $paths, $path );

my $q     = new CGI;
my $query = $q->param("query");
$query = "value";
my @words = split /\s*(,|\s+)/, $query;

tie %index,'Tie::DBI','mysql:test:slug;user=scherer;password=kks','test','id',{CLOBBER=>1}
    or die "Cannot tie database: $!\n";

#tie %index, "DB_File", INDEX_DB, O_RDONLY, 0640
#    or error( $q, "Cannot open database" );

$paths = search( \%index, \@words );

print $q->header,
      $q->start_html( "Inverted Index Search" ),
      $q->h1( "Search for: $query" );

unless ( @$paths ) {
    print $q->h2( $q->font( { -color => "#FF000" }, 
                            "No Matches Found" ) );
}
    $ENV{DOCUMENT_ROOT} = 'C:\Users\scherer\Desktop\Stock';

foreach $path ( @$paths ) {
    my $file = basename( $path );
    next unless $path =~ s/^\Q$ENV{DOCUMENT_ROOT}\E//o;
    $path = to_uri_path( $path );
    print $q->a( { -href => "$path" }, "$path" ), $q->br;
} 

print $q->end_html;
untie %index;



sub search {
    my( $index, $words ) = @_;
    my $do_stemming = exists $index{"!OPTION:stem"}->{value} ? 1 : 0;
    my $ignore_case = exists $index{"!OPTION:ignore"}->{value} ? 1 : 0;
    my( %matches, $word, $file_index );
    
    foreach $word ( @$words ) {
        my $match;
        
        if ( $do_stemming ) {
            my( $stem )  = stem( $word );
            $match = $index->{$stem};
        }
        elsif ( $ignore_case ) {
            $match = $index{lc $word}->{value};
        }
        else {
            $match = $index{$word}->{value};
        }
        
        next unless $match;
        
        foreach $file_index ( split /:/, $match ) {
            my $filename = $index{"!FILE_NAME:$file_index"}->{value};
            $matches{$filename}++;
        }
    }
    my @files = map  { $_->[0] }
                sort { $matches{$a->[0]} <=> $matches{$b->[0]} || 
                       $a->[1] <=> $b->[1] }
                map  { [ $_, -M $_ ] }
                keys %matches;
    
    return \@files;
}

sub to_uri_path {
    my $path = shift;
    my( $name, @elements );
    
    $path =~ s/.*:(.*)/$1/;
    do {
        ( $name, $path ) = fileparse( $path );
        unshift @elements, $name;
        chop $path;
	print STDERR "$path\n";
    } while $path;
    
    return join '/', @elements;
}

