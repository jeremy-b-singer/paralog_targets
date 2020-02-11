truncate table hmmer_statistics_import;

\copy hmmer_statistics_import from 'hmm_stats.txt' delimiter E'\t' CSV HEADER


insert into hmmer_statistics
( target, tlen, orf, qlen, evalue, score)
select target, tlen, orf, qlen, evalue, score
from hmmer_statistics_import;

