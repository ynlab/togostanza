class GenomeProjectsStanza < TogoStanza::Stanza::Base
  property :projects do |taxonomy_id|
    #query('http://ep.dbcls.jp/sparql-import', <<-SPARQL.strip_heredoc)
    #query('http://dev.togogenome.org/sparql-test', <<-SPARQL.strip_heredoc)
    #query('http://dev.togogenome.org/sparql', <<-SPARQL.strip_heredoc)
    taxonomy_id = 1117 if taxonomy_id.blank?
    query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)
DEFINE sql:select-option "order"

PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>

select  ?id,?link,?organism_name,?taxon,?bioproject_accession,?biosample_accession, ?level, ?release_date, replace(str($taxon),"http://identifiers.org/taxonomy/","") as ?taxid
#FROM <http://togogenome.org/graph/taxonomy>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
#FROM <http://togogenome.org/graph/assembly_report>
FROM <http://genome.microbedb.jp/cyanobase/assembly>
WHERE
{
#values ?taxon_root { tax:1117 tax:147537 tax:147545 tax:451866 tax:3041 tax: 2763 tax:33090}
values ?taxon_root { tax:#{taxonomy_id}}
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
}
ORDER BY desc(?release_date)
    SPARQL
end
  property :projects_sum do |taxonomy_id|
     taxonomy_id = 1117 if taxonomy_id.blank?
     #query('http://ep.dbcls.jp/sparql-import', <<-SPARQL.strip_heredoc)
     query('http://staging-genome.annotation.jp/sparql', <<-SPARQL.strip_heredoc)

DEFINE sql:select-option "order"

PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
PREFIX tax: <http://identifiers.org/taxonomy/>

select  distinct ?level count(?id) as ?number
#FROM <http://togogenome.org/graph/taxonomy>
#FROM <http://togogenome.org/graph/assembly_report>
FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy>
FROM <http://genome.microbedb.jp/cyanobase/assembly>
#

WHERE
{
#values ?taxon_root { tax:1117 tax:147537 tax:147545 tax:451866 tax:3041 tax: 2763 tax:33090}
values ?taxon_root { tax:#{taxonomy_id}}
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
}
GROUP BY ?level
    SPARQL
  end
end
