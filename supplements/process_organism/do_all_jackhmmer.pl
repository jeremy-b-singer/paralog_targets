#!/usr/bin/perl
# do_all_jackhmmer.pl
# Applies jackhmmer to .FASTA files in chromosome directories under <organism directory>
#

if (scalar(@ARGV) < 1) { die ("Specify organism directory\n"); }
my $org_dir = pop(@ARGV);

if ( !( -e $org_dir and -d $org_dir ) ) {
	 die "$org_dir is not a directory\n";
}

my @chrom_dirs = glob("$org_dir*");
foreach my $chrom (@chrom_dirs) {
	my @fastas = glob("$chrom/*.FASTA");
	foreach my $fasta (@fastas) {
		if ( !( -e "$fasta.summary" ) ) {
			print "jackhmmer $fasta\n";
			system("jackhmmer --domtblout $fasta.summary -o $fasta.hmm.txt $fasta ~/hmmer_targets/component_sequences.fa");
		}
	}
}

