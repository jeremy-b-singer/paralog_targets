#!/bin/bash
if [ -z $1 ]
then
	while [ -z $org_dir ]
	do
		read -p "Organism directory: " -a org_dir
	done
else 
	org_dir=$1
fi
echo $org_dir

echo "target	tlen	orf	qlen	evalue	score" > hmm_stats.txt
for chrom_dir in $( ls -d $org_dir*/ );do
	for orf in $( grep -L "\[No hits" $chrom_dir*hmm.txt ); do
		perl ~/genomes/extract_hmm_summary.pl $orf >> hmm_stats.txt
	done
done
