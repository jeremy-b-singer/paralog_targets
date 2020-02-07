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

for chrom_dir in $( ls -d $org_dir*/ );do
	for orf in $( ls $chrom_dir*.blastp.txt);do
		echo "BLAST stats " $orf
		 perl ~/genomes/extract_header.pl < ${orf} > ${orf}.stats
	done
done
