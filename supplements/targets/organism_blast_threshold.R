# organism_blast_threshold.R
# computes median + mad based threshold for selecting targets.

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

get_blast_threshold=function(conn,tax_id,num_mad_intervals=2){
  q_org_score = paste0(
    'select distinct score, orf_id, target
    from blast_statistics b
    join target_dictionary td 
    on b.target = td.chembl_id 
    join drug_mechanism dm 
    ON dm.tid = td.tid 
    join molecule_dictionary md 
    ON dm.molregno = md.molregno 
    WHERE b.tax_id ='
    , tax_id
  )
  org_score=dbGetQuery(conn, q_org_score)
  attach(org_score)
  med=median(org_score$score)
  mi=mad(org_score$score)
  thresh=med+num_mad_intervals*mi
  detach()
  return(thresh)
}

