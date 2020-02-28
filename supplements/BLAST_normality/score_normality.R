# score normality
stats=read.csv(file='../process_plasmodium/blast_statistics.txt', sep="\t", stringsAsFactors = FALSE)
organism="P. falciparum 3D7"

attach(stats)
qqnorm(log(score),main='Q-Q Plot for BLASTP log(scores)')
qqline(log(score),col='red',lwd=3)
detach()

norm_log_thresh=median(log(stats$score))+2*mad(log(stats$score))
norm_thresh=median(stats$score)+2*mad(stats$score)
print(paste('norm_log_thresh:',norm_log_thresh))
print(paste('norm_thresh:', norm_thresh))

norm=stats[log(stats$score) < norm_log_thresh,]
qqnorm(log(norm$score), main='Q-Q Plot for log normal scores')
qqline(log(norm$score), lwd=3, col='red')

highly_similar=stats[stats$score > norm_thresh,]

consolidated_stats=read.csv(file = "consolidated_stats.txt", sep='\t', stringsAsFactors = FALSE)
attach(consolidated_stats)
qqnorm(log(hmmer_score),main='Q-Q Plot for HMMER log(scores)')
qqline(log(hmmer_score),lwd=3,col='red')

# kmeans analysis

kh=kmeans(hmmer_score,2,nstart=25)
k_threshold = min(hmmer_score[kh$cluster==1])
plot(hmmer_score,col=kh$cluster,main='2 kmeans clusters for hmmer_score', 
     sub=paste('Significance threshold:',k_threshold))
print(paste('Kmeans threshold for significance:', k_threshold))
abline(h=k_threshold,lwd=3, col='purple')
detach()

