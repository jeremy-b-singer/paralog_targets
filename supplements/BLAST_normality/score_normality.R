# score normality
stats=read.csv(file='../process_plasmodium/blast_statistics.txt', sep="\t", stringsAsFactors = FALSE)
organism="P. falciparum 3D7"

attach(stats)
qqnorm(log(score),main='Q-Q Plot for BLASTP log(scores)',lwd=3)
qqline(log(score),col='red')
detach()