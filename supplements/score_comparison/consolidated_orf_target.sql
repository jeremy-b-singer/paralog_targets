\copy ( select h.orf, b.target,b.score as blast_score, h.score as hmmer_score, b.expect as blast_expect, h.evalue FROM blast_statistics b join hmmer_statistics h on b.orf_id = h.orf and b.target = h.target) to C:\Users\Jeremy-satellite\Documents\RBIF120\consolidated_stats.txt CSV delimiter '	'

