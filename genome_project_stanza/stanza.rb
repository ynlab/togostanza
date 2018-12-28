class GenomeProjectStanza < TogoStanza::Stanza::Base
  property :select_project_id do |project_id|
    project_id
  end

  property :select_organism_name do |project_id|
    project_id = 'GCA_000009725.1' if project_id.blank?
   list = query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
 DEFINE sql:select-option "order"
PREFIX asm: <http://ddbj.nig.ac.jp/ontologies/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>
SELECT
  ?organism_name ?assembly_id
#FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy_20181219>
#FROM <http://genome.microbedb.jp/cyanobase/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly>
WHERE
{
  ?assembly asm:organism_name ?organism_name.
  ?assembly asm:assembly_id "#{project_id}"
} LIMIT 1
SPARQL
  list.first['organosm_name']
   end

  resource :project_metadata do |project_id|
    project_id = 'GCA_000009725.1' if project_id.blank?
      list = query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)

 DEFINE sql:select-option "order"

#PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX asm: <http://ddbj.nig.ac.jp/ontologies/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>

select 
#distinct 
replace(str(?k),"http://ddbj.nig.ac.jp/ontologies/assembly/","") as ?k ?v
#?id,?link,?organism_name,?taxon,?bioproject_accession,?biosample_accession, ?level, ?release_date, replace(str($taxon),"http://identifiers.org/taxonomy/","") as ?taxid
#FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy_20181219>
#FROM <http://genome.microbedb.jp/cyanobase/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly>
WHERE
{
#values ?taxon_root { tax:1117}
#values ?version_status {"latest"}.
values ?k {
#<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
#<http://www.w3.org/2000/01/rdf-schema#seeAlso>
<http://ddbj.nig.ac.jp/ontologies/assembly/asm_name>
<http://ddbj.nig.ac.jp/ontologies/assembly/assembly_id>
<http://ddbj.nig.ac.jp/ontologies/assembly/assembly_level>
<http://ddbj.nig.ac.jp/ontologies/assembly/bioproject>
<http://ddbj.nig.ac.jp/ontologies/assembly/bioproject_accession>
<http://ddbj.nig.ac.jp/ontologies/assembly/biosample>
<http://ddbj.nig.ac.jp/ontologies/assembly/biosample_accession>
<http://ddbj.nig.ac.jp/ontologies/assembly/excluded_from_refseq>
<http://ddbj.nig.ac.jp/ontologies/assembly/ftp_path>
<http://ddbj.nig.ac.jp/ontologies/assembly/gbrs_paired_asm>
<http://ddbj.nig.ac.jp/ontologies/assembly/genome_rep>
<http://ddbj.nig.ac.jp/ontologies/assembly/infraspecific_name>
<http://ddbj.nig.ac.jp/ontologies/assembly/isolate>
<http://ddbj.nig.ac.jp/ontologies/assembly/organism_name>
<http://ddbj.nig.ac.jp/ontologies/assembly/paired_asm_comp>
<http://ddbj.nig.ac.jp/ontologies/assembly/refseq_category>
<http://ddbj.nig.ac.jp/ontologies/assembly/relation_to_type_material>
<http://ddbj.nig.ac.jp/ontologies/assembly/release_date>
<http://ddbj.nig.ac.jp/ontologies/assembly/release_type>
<http://ddbj.nig.ac.jp/ontologies/assembly/species_taxid>
<http://ddbj.nig.ac.jp/ontologies/assembly/submitter>
<http://ddbj.nig.ac.jp/ontologies/assembly/tax_id>
<http://ddbj.nig.ac.jp/ontologies/assembly/taxon>
<http://ddbj.nig.ac.jp/ontologies/assembly/version_status>
<http://ddbj.nig.ac.jp/ontologies/assembly/wasDerivedFrom>
<http://ddbj.nig.ac.jp/ontologies/assembly/wgs_master>
<http://ddbj.nig.ac.jp/ontologies/assembly/molecule-count>
<http://ddbj.nig.ac.jp/ontologies/assembly/region-count>
#<http://ddbj.nig.ac.jp/ontologies/assembly/sequence>
<http://ddbj.nig.ac.jp/ontologies/assembly/spanned-gaps>
<http://ddbj.nig.ac.jp/ontologies/assembly/top-level-count>
<http://ddbj.nig.ac.jp/ontologies/assembly/total-gap-length>
<http://ddbj.nig.ac.jp/ontologies/assembly/total-length>
<http://ddbj.nig.ac.jp/ontologies/assembly/unspanned-gaps>
<http://ddbj.nig.ac.jp/ontologies/assembly/contig-N50>
<http://ddbj.nig.ac.jp/ontologies/assembly/contig-count>
}

#values ?derived_from {<http://identifiers.org/insdc> <http://identifiers.org/refseq>}
#?taxon_root a <http://ddbj.nig.ac.jp/ontologies/taxonomy/Taxon> .
#?taxon rdfs:subClassOf* ?taxon_root.
#?assembly asm:assembly_id "GCA_001438415.1";
?assembly asm:assembly_id "#{project_id}";
#rdf:type ?derived_from;
?k ?v.

}
SPARQL
 list
end

  resource :project do |project_id|
    project_id = 'GCA_000009725.1' if project_id.blank?
    list = query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
 DEFINE sql:select-option "order"

#PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX asm: <http://ddbj.nig.ac.jp/ontologies/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>

select  ?id,?link,?organism_name,?taxon,?bioproject_accession,?biosample_accession, ?level, ?release_date, replace(str($taxon),"http://identifiers.org/taxonomy/","") as ?taxid
#FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy_20181219>
#FROM <http://genome.microbedb.jp/cyanobase/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly>
WHERE
{
#values ?taxon_root { tax:1117 tax:147537 tax:147545 tax:451866 tax:3041 tax: 2763 tax:33090}
values ?taxon_root { tax:1117}
#values ?category {"representative genome"}.
values ?version_status {"latest"}.

?taxon_root a <http://ddbj.nig.ac.jp/ontologies/taxonomy/Taxon> .
?taxon rdfs:subClassOf* ?taxon_root.
?assembly asm:taxon ?taxon;
 asm:refseq_category ?category;
 asm:asm_name ?name;
 asm:assembly_id ?id;
 #asm:assembly_accession ?id;
 asm:assembly_level ?level;
 asm:bioproject ?bioproject;
 asm:bioproject_accession ?bioproject_accession;
 asm:biosample_accession ?biosample_accession;
 asm:gbrs_paired_asm ?gbrs_paired_asm;
 asm:genome_rep ?rep;
 asm:infraspecific_name ?infraspecific_name;
 asm:isolate ?isolate;
 asm:organism_name ?organism_name;
 asm:paired_asm_comp ?paired_asm_comp;
 asm:release_date ?release_date;
 asm:release_type ?release_type;
 asm:species_taxid ?species_taxid;
 asm:submitter ?submitter;
 asm:tax_id ?tax_id;
 asm:taxon ?taxon;
 asm:version_status ?version_status;
 asm:wgs_master ?wgs_master;
 rdfs:seeAlso ?link.
 FILTER(?id = "#{project_id}")
}
ORDER BY desc(?release_date)
SPARQL
   list
  end
   
  resource :sequences do |project_id|
    project_id = 'GCA_000009725.1' if project_id.blank?
    list = query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
 DEFINE sql:select-option "order"

#PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX asm: <http://ddbj.nig.ac.jp/ontologies/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>

select
#?id,?link,?organism_name,?taxon,?bioproject_accession,?biosample_accession, ?level, ?release_date, replace(str($taxon),"http://identifiers.org/taxonomy/","") as ?taxid, ?genbank_accession, ?genbank, ?assigned_molecule_location_type
?genbank_accession, ?genbank, ?assigned_molecule_location_type
#FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy_20181219>
#FROM <http://genome.microbedb.jp/cyanobase/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly>
WHERE
{
values ?taxon_root { tax:1117}
values ?version_status {"latest"}.

?taxon_root a <http://ddbj.nig.ac.jp/ontologies/taxonomy/Taxon> .
?taxon rdfs:subClassOf* ?taxon_root.
?assembly asm:taxon ?taxon;
 asm:refseq_category ?category;
 asm:asm_name ?name;
 asm:assembly_id ?id;
 #asm:assembly_accession ?id;
 asm:assembly_level ?level;
 asm:bioproject ?bioproject;
 asm:bioproject_accession ?bioproject_accession;
 asm:biosample_accession ?biosample_accession;
 asm:gbrs_paired_asm ?gbrs_paired_asm;
 asm:genome_rep ?rep;
 asm:infraspecific_name ?infraspecific_name;
 asm:isolate ?isolate;
 asm:organism_name ?organism_name;
 asm:paired_asm_comp ?paired_asm_comp;
 asm:release_date ?release_date;
 asm:release_type ?release_type;
 asm:species_taxid ?species_taxid;
 asm:submitter ?submitter;
 asm:tax_id ?tax_id;
 asm:taxon ?taxon;
 asm:version_status ?version_status;
 asm:wgs_master ?wgs_master;
 asm:sequence ?seq;
 rdfs:seeAlso ?link.
 ?seq asm:assigned_molecule_location_type ?assigned_molecule_location_type.
 ?seq asm:genbank_accession   ?genbank_accession.
 ?seq asm:genbank ?genbank.
 FILTER(?id = "#{project_id}")
}
ORDER BY desc(?release_date)
SPARQL
   list
  end
end
