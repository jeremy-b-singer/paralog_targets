#######################################
# split_to_fasta.pl
# input recs: <key><delim><sequence>
# output : rec1 = ><key>
#          rec2 = <sequence>
#######################################
my $infile = 'chembl_targets.txt';
my $outfile = 'component_sequences.fa';
my $delim = '\t';

open(IN, $infile) or die("Unable to open $infile\n");

my @lines = <IN>;

close(IN);

open(OUT,">",$outfile) or die ("Unable to open $outfile\n");

foreach my $line(@lines)
{
	my @rec = split($delim,$line);
	if (scalar(@rec) > 1)
	{
		print OUT ">$rec[0]\n";
		print OUT "$rec[1]\n";
	}
}

close(OUT);
exit(0);
