#!/bin/perl

use Switch;

if (scalar(@ARGV) < 1) {die "No filename passed.\n";}

my $text_fn	= $ARGV[0];
my $summary_fn;

# print $text_fn,"\n";
$summary_fn	= $text_fn;
$summary_fn	=~ s/.hmm.txt/.summary/;
# print $summary_fn,"\n";

my @lines;

open($IN, "<", $summary_fn ) or die "Can't open $summary_fn\n";
@lines = <$IN>;
close($IN);
# print "Lines: ",scalar(@lines), "\n";

my %target;

foreach my $line(@lines){
	if ( $line =~ m/^(CHEMBL\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/ ) {
		if ( ! exists $target{$1} ) { # prevent duplicate line for a target match
			print $1,"\t", $3, "\t", $4,"\t",$6, "\t", $7, "\t", $8, "\n";
			$target{$1} = 1;
		}
	}
}
