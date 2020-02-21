# Scores comparison
consolidated_stats=read.csv(file = "consolidated_stats.txt", sep='\t', stringsAsFactors = FALSE)
attach(consolidated_stats)
plot(blast_score,hmmer_score,main='Comparison of BLASTP vs HMM scores for P. falciparum with targets')
abline(a=0,b=median(hmmer_score/blast_score)+mad(hmmer_score/blast_score),col='red')
detach()
