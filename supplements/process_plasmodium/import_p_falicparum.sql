truncate table blast_statistics_import;
\copy blast_statistics_import from 'blast_statistics.txt' delimiter E'\t' CSV HEADER

insert into blast_statistics
( tax_id, organism, orf_id, target, query_length, score, expect, identities, positives, gaps)
SELECT 36329 -- tax_id
	, 'Plasmodium falciparum 3D7'
	, orf_id
	, target
	, query_length
	, score
	, expect
	, identities
	, positives
	, gaps
FROM blast_statistics_import;
