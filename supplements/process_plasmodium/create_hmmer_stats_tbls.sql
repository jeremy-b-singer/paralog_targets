CREATE TABLE hmmer_statistics
(
	hmmer_statistics_id	SERIAL
	, tax_id numeric
	, organism character varying(100)
	, chromosome character varying(50)
	, target character varying(50)
	, tlen	int
	, orf	character varying(50)
	, qlen	int
	, evalue numeric
	, score numeric
	, import_date timestamp not null default clock_timestamp()
);

CREATE TABLE hmmer_statistics_import
(
	  target character varying(50)
        , tlen  int
        , orf   character varying(100)
        , qlen  int
        , evalue numeric
        , score numeric
);
