select distinct h.target, score, td.tax_id as original_tax_id, td.organism as orig_organism,td.pref_name, md.pref_name, md.chembl_id
from hmmer_statistics h
     join target_dictionary td
     on h.target = td.chembl_id
     join drug_mechanism dm
     ON dm.tid = td.tid
     join molecule_dictionary md
     ON dm.molregno = md.molregno
WHERE h.tax_id = 36329
 -- and td.tax_id !=9606
  and score >= 385.3
order by score desc;
