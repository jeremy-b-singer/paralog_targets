CREATE TABLE blast_statistics
(
	  sk_blast_statistics SERIAL -- synthetic primary key
	, tax_id bigint				 -- NCBI taxonomy id of target
	, organism character varying(100) 	 -- convenience name of organism
	, chromosome character varying(50)
	, orf_id character varying(50)
	, target character varying(50) 		 -- typically, chembl_id
	, query_length int
	, score numeric
	, expect numeric
	, identities numeric
	, positives numeric
	, gaps numeric
	, import_date timestamp not null default clock_timestamp()
);

CREATE TABLE blast_statistics_import
(
	orf_id character varying(50)
	, target character varying(50)
	, query_length int
	, score numeric
	, expect numeric
	, identities numeric
	, positives numeric
	, gaps numeric
);
