\copy (select td.chembl_id, cs.sequence from target_dictionary td join target_components tc on td.tid = tc.tid join component_sequences cs on tc.targcomp_id=cs.component_id) to chembl_targets.txt

