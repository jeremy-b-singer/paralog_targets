# BLAST histogram and normal behavior
stats=read.csv(file='../process_plasmodium/blast_statistics.txt', sep="\t", stringsAsFactors = FALSE)
organism="P. falciparum 3D7"
dmax=dnorm(0,mean=0,sd=1)
sig=dmax/2.06745

# scores are log normally distributed

attach(stats)
h= hist(log(stats$score),breaks=length(stats$score)/20,main= paste("Histogram log(score) for",organism))
xmean=match(max(h$counts),h$counts)

n=function(x){
  dnorm(x,mean=median(log(stats$score))-h$density[1]/2,sd=mad(log(stats$score))*1.1) * max(h$counts) * sig
}

curve(n,from=3,to=8,add=TRUE,col='red')

thresh=median(log(score))+1*mad(log(score))
abline(v=thresh,col='blue')
points(thresh,max(h$counts),pch='1')
thresh=median(log(score))+2*mad(log(score))
abline(v=thresh,col='blue')
points(thresh,max(h$counts),pch='2')
thresh=median(log(score))+3*mad(log(score))
abline(v=thresh,col='blue')
points(thresh,max(h$counts),pch='3')
thresh=median(log(score))+4*mad(log(score))
points(thresh,max(h$counts),pch='4')
abline(v=thresh,col='blue')

detach()

