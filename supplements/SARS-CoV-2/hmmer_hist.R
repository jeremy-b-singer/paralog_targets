library(RPostgres)

db_name='chembl_25'
user_name = 'postgres'
host='192.168.1.180'
port=5432

conn = dbConnect(drv=RPostgres::Postgres(),
                 dbname=db_name,
                 user=user_name,
                 host=host,
                 port=port)
organism='SARS-CoV-2'
dmax=dnorm(0,mean=0,sd=1)
sig=dmax/2.06745

q_hmmer_statistics_SARS_COV_2="
select avg(score) as score
      , td.tax_id as original_tax_id
      , td.organism as orig_organism
      , md.pref_name
      , md.chembl_id
      , dm.mechanism_of_action
      , md.max_phase
      , md.first_approval 
from hmmer_statistics h
    join target_dictionary td
    on h.target = td.chembl_id
    join drug_mechanism dm
    ON dm.tid = td.tid
    join molecule_dictionary md
    ON dm.molregno = md.molregno 
    WHERE h.tax_id = 2697049
group by td.tax_id
  , td.organism
  , md.pref_name
  , md.chembl_id
  , dm.mechanism_of_action
  , md.max_phase
  , md.first_approval order by pref_name"

drugs=dbGetQuery(conn,q_hmmer_statistics_SARS_COV_2)
dbDisconnect(conn)

attach(drugs)
h= hist(log(score),breaks=20,main= paste("Histogram of log(score) for",organism))
xmean=match(max(h$counts),h$counts)

detach()