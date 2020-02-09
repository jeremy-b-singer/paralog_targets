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

echo "orf_id	target	query_length	score	expect	identities	positives	gaps" > blast_statistics.txt
for chrom_dir in $( ls -d $org_dir*/ );do
	cat  $( ls $chrom_dir*.blastp.txt.stats) >> blast_statistics.txt
done
