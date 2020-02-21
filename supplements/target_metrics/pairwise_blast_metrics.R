# pairwise comparison of BLAST statistics

blast_statistics=read.csv(file='blast_statistics.txt', sep="\t", stringsAsFactors = FALSE)
blast_values = data.frame(score=log(blast_statistics$score), expect=blast_statistics$expect,
                          identities=blast_statistics$identities, positives=blast_statistics$positives)
pairs(blast_values)
