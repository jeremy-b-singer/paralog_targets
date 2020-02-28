# BLAST histogram and normal behavior
stats=read.csv(file='../process_plasmodium/blast_statistics.txt', sep="\t", stringsAsFactors = FALSE)
organism="P. falciparum 3D7"
dmax=dnorm(0,mean=0,sd=1)
sig=dmax/2.06745

# scores are log normally distributed

h= hist(log(stats$score),breaks=length(stats$score)/20,main= paste("Histogram log(score) for",organism))
xmean=match(max(h$counts),h$counts)

n=function(x){
  dnorm(x,mean=median(log(stats$score))-h$density[1]/2,sd=mad(log(stats$score))*1.1) * max(h$counts) * sig
}

curve(n,from=3,to=8,add=TRUE,col='red')

for (i in 1:5){
  thresh=median(log(stats$score))+i*mad(log(stats$score))
  abline(v=thresh,col='blue')
  points(thresh,max(h$counts),pch=as.character(i))
}

hmmer_hist=hist(log(consolidated_stats$hmmer_score),breaks=length(consolidated_stats$hmmer_score)/20)


