# Fan out AA_fasta file from CryptoDB
# based on the structure of Plasmodium AA_orf files.
# FASTA headers come in two varieties:
# 1. >Pf3D7_01_v3-1-60871-61059 | organism=Plasmodium_falciparum_3D7 | location=Pf3D7_01_v3:60871-61059(+) | length=63 | sequence_SO=chromosome
#     ^unique ORF identifier---^  <other stuff> <sequence_SO=<ORF type> i.e. chromosome, apicoplast, mitochondrial
#    ^head indicator
#     ^organism
#           ^chromosome id
#              ^orf_name
# 2. >Pf_M76611-5-344-75 | organism=Plasmodium_falciparum_3D7 | location=Pf_M76611:75-344(-) | length=90 | sequence_SO=mitochondrial_chromosome
#     ^orfname---------^   <other stuff>  sequence_SO=mitochondrial_chromosome
# parsing strategy is: for non-mitochondrial, parse out chromosome_name, orf_name.  
# For mitochondrial, orfname is one piece.
library(stringr)
setwd('~/genomes')
aa_file=file.choose()
aa=read.table(file=aa_file,header = FALSE, sep='~', stringsAsFactors = FALSE)
aa=aa[!is.na(aa[,1]),] # filter out NA
firstrec=aa[1] # scalar
aa=data.frame(lines=aa, stringsAsFactors = FALSE)
parsed=strsplit(firstrec,'_')
organism_pref=substring(parsed[[1]][1],2)

# make a directory for this organism
system(paste('mkdir',organism_pref))

orf_headers=aa[substr(aa[,1],1,1)=='>' ,]
mi_headers=orf_headers[grep('sequence_SO=mitochondrial_chromosome',orf_headers)]
chrom_headers = setdiff(orf_headers, mi_headers)
parsed=strsplit(chrom_headers,'_')
chromosomes=unique(sapply(parsed,function(p){
  unlist(strsplit(p[2],'-'))[1]
  })
  )

# make a directory for each chromosome
for (chromosome in chromosomes){
  dirname=paste(organism_pref,chromosome,sep='/')
  system(paste('mkdir',dirname))
}

dirname=paste(organism_pref,'mitochondrion', sep='/')
system(paste('mkdir',dirname))

orf.df = data.frame(line='')
orf_name=''
orf.df=data.frame(line='')
for(orf_line in aa[,1]){
  print(paste('orf_line: ',orf_line))
  if (substr(orf_line,1,1)=='>'){
    print('FASTA header line')
    if ( is.na(orf_name) || nchar(orf_name) > 0){
      orf_name=paste0(orf_name,'.FASTA')
      print("write statement")
      write_dir_name = paste(organism_pref,chromosome, orf_name,sep='/')
      write.table(orf.df, file=write_dir_name,row.names = FALSE,col.names = FALSE, quote=FALSE)
    } # end if orf_name has been previously accumulated
    orf.df = data.frame(line=orf_line) # header line set in df
    if ( length(grep('mitochondrial',orf_line)) > 0){ # it goes to mitochondrion
      chromosome='mitochondrion'
      print(paste("Chromosome:", chromosome))
      parsed=unlist(strsplit(orf_line,' '))
      orf_name=substr(parsed[1],2,nchar(parsed[1]) -1)
    } else { # not mitochondrion, find chromosome
      parsed=unlist(strsplit(orf_line,' '))
      parsed=unlist(strsplit(parsed[1],'_'))
      if (length(parsed) > 1){
        orf_name=paste0(parsed[2],'.FASTA')
        parsed=unlist(strsplit(orf_name,'-'))
        chromosome=parsed[1]
        print(paste('chromosome:',chromosome,', orf_name:', orf_name))
      }
    } # end is empty
  } # end is header line 
  else {
    print('rbind FASTA sequence')
    orf_line.df=data.frame(line=orf_line)
    orf.df = rbind(orf.df, orf_line.df);
    
    write_dir_name = paste(organism_pref,chromosome, orf_name,sep='/')
    print(paste("write to :",write_dir_name))
    write.table(orf.df, file=write_dir_name,row.names = FALSE,col.names = FALSE,quote=FALSE)
  }
}
if (is.na(orf_name) || nchar(orf_name) > 0){
  print("write statement")
  write_dir_name = paste(organism_pref,chromosome, orf_name,sep='/')
  write.table(orf.df, file=write_dir_name,row.names = FALSE,col.names = FALSE,quote=FALSE)
}