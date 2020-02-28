select distinct b.target, score, td.tax_id as original_taxid, td.pref_name
from blast_statistics b
     join target_dictionary td
     on b.target = td.chembl_id
     join drug_mechanism dm
     ON dm.tid = td.tid
     join molecule_dictionary md
     ON dm.molregno = md.molregno
WHERE b.tax_id = 36329
  and score > 246
order by score desc;
