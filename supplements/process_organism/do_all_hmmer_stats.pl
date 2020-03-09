#!/usr/bin/perl
# do_all_hmmer_stats.pl
# Gathers jackhmmer stats in chromosome directories under <organism directory>
#

if (scalar(@ARGV) < 1) { die ("Specify organism directory\n"); }
my $org_dir = pop(@ARGV);

if ( !( -e $org_dir and -d $org_dir ) ) {
	 die "$org_dir is not a directory\n";
}

my $hdr = "target\ttlen\torf\tqlen\tevalue\tscore\n";
open(OUT, '>','hmm_stats.txt');
print OUT $hdr;
close(OUT);

my @chrom_dirs = glob("$org_dir*");
foreach my $chrom (@chrom_dirs) {
	my @fastas = glob("$chrom/*.FASTA");
	foreach my $fasta (@fastas) {
		print( "Extract hmm stats for $fasta\n");
		system("perl ~/genomes/extract_hmm_summary.pl $fasta.summary >> hmm_stats.txt");
	}
}

