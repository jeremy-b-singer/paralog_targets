#get_unique_drugs(conn, tax_id)

get_unique_drugs=function (conn, tax_id, threshold){
  where_clause = paste0('WHERE score >= ', threshold, ' and h.tax_id=',tax_id,
                        ' and md.first_approval is not null')
  
  q_unique_drugs=paste(  'SELECT max(h.score) as score, md.pref_name '
                        ,'from hmmer_statistics h'
                        , '    join target_dictionary td'
                        , '    ON h.target = td.chembl_id'
                        , '    JOIN drug_mechanism dm'
                        , '    ON td.tid = dm.tid'
                        , '    JOIN molecule_dictionary md'
                        , '    ON dm.molregno = md.molregno'
                        , where_clause
                        , 'group by md.chembl_id, md.pref_name'
                        , 'ORDER BY md.pref_name')
  
  drugs = dbGetQuery(conn,q_unique_drugs)
  return(drugs)
}
