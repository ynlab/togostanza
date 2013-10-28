class TaxonomyOrthologProfileStanza < TogoStanza::Stanza::Base
  property :title do |tax_id|
    "Orthologs of tax: #{tax_id}, number of members"
  end

  property :param_tax_id do |tax_id|
    tax_id
  end

  resource :taxonomy_ortholog_profile do |tax_id|
    ortholog_uris = query("http://sparql.nibb.ac.jp/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX mbgd: <http://mbgd.genome.ad.jp/owl/mbgd.owl#>
      PREFIX orth: <http://mbgd.genome.ad.jp/owl/ortholog.owl#>
      PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
      PREFIX uniprotCore: <http://purl.uniprot.org/core/>
      PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
 
      SELECT ?group ?comment COUNT(?member) AS ?count
      WHERE {
        ?tax rdfs:subClassOf+ taxon:#{tax_id} .
        ?organism orth:taxon ?tax .
        ?member mbgd:organism ?organism .
        ?group orth:member ?member ;
          mbgd:description ?comment ;
          a orth:OrthologGroup .
      } ORDER BY DESC (?count) limit 10
    SPARQL
  end
end
