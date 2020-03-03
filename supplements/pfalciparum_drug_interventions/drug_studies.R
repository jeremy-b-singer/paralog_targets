setwd('../pfalciparum_drug_interventions')
drug_studies=read.csv(file="pfalciparum_stadies.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
drug_interventions=drug_studies[grep('Drug:',drug_studies$Interventions),]

intervention=drug_interventions[1,'Interventions']
pfalciparum_drugs=read.csv(file="../targets/P_falciparum_hmmer_drugs.txt", header=TRUE, sep="\t", stringsAsFactors = FALSE)

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

q_chembl_id = 
  'SELECT md.chembl_id
   FROM molecule_dictionary md
        JOIN molecule_synonyms ms
        ON md.moleregno = ms.molregno
   WHERE lower(synonyms) like lower('


parse_drugs=function(str){
  sub=unlist(strsplit(str,'[|]'))
  sub=unlist(strsplit(sub,'Drug: '))
  sub=unlist(strsplit(sub,'-'))
  sub=unlist(strsplit(sub,' '))
  sub=unlist(strsplit(sub,'/'))
  return(sub)
}

get_chembl_id=function(con, name){
  if (is.na(name)){return(NULL)}
  if (nchar(name) < 1){ return(NULL)}
  
  q_chembl_id = paste0(
    'SELECT distinct md.chembl_id
   FROM molecule_dictionary md
        JOIN molecule_synonyms ms
        ON md.molregno = ms.molregno
   WHERE lower(synonyms) like lower( \'', name, '\')')
  
  id_value=dbGetQuery(con, q_chembl_id)
  if (dim(id_value)[1] < 1){ return(NULL) }
  
  return(id_value[1])
}

study_drugs=list()
for (study in 1:dim(drug_studies)[1]){
  drug_names = parse_drugs(drug_interventions$Interventions[study])
  if (is.na(drug_names)) next
  study_drugs[[study]]=paste0(unlist(sapply(drug_names, function(name){
    get_chembl_id(conn, name)
  })),collapse = ',')
}

study_drugs_chembl_id=data.frame(title=drug_interventions$Title, status=drug_interventions$Status
                                 ,results=drug_interventions$Study.Results,url=drug_interventions$URL
                                 , chembl_ids=unlist(study_drugs))

validated=pfalciparum_drugs[pfalciparum_drugs$chembl_id %in% study_drugs_chembl_id$chembl_ids,]

