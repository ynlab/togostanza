class GenomeProjectsStanza < TogoStanza::Stanza::Base

  property :select_taxonomy_id do |taxonomy_id|
    taxonomy_id
  end

  resource :projects do |taxonomy_id|
    taxonomy_id = 1117 if taxonomy_id.blank?
    list = query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
DEFINE sql:select-option "order"

#PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX asm: <http://ddbj.nig.ac.jp/ontologies/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX mdb: <http://genome.microbedb.jp/terms#>
select
?id,?link,?organism_name,?taxon,?bioproject_accession,?biosample_accession, ?level, ?release_date, replace(str($taxon),"http://identifiers.org/taxonomy/","") as ?taxid,?assembly, ?mdb_uri, ?project_current, ?project_next, ?genepage_status, ?nies_id, ?project_status
#FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy_20181219>
#FROM <http://genome.microbedb.jp/cyanobase/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly>
FROM <http://genome.microbedb.jp/cyanobase_201812/assembly_extended>
WHERE
{
#values ?taxon_root { tax:1117 tax:147537 tax:147545 tax:451866 tax:3041 tax: 2763 tax:33090}
values ?taxon_root { tax:#{taxonomy_id}}
#values ?taxon_root { tax:1117}

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
?mdb_uri skos:relatedMatch ?assembly;
  mdb:project_current ?project_current;
  mdb:project_next ?project_next;
  mdb:project_latest ?project_latest;
  mdb:genepage_status ?genepage_status;
  mdb:nies_id ?nies_id;
  mdb:project_statue ?project_status.

}
ORDER BY desc(?release_date)
    SPARQL
list
  end
end
