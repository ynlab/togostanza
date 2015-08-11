require 'net/http'
require 'uri'
require 'bio'

class GeneAttributesStanza < TogoStanza::Stanza::Base
  property :gene_attributes do |tax_id, gene_id|
    results = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>

      SELECT DISTINCT
        ?locus_tag ?gene_type_label ?gene_name
        ?refseq_link ?seq_label ?seq_type_label ?refseq_label ?organism ?tax_link
        ?strand ?insdc_location
      WHERE
      {
        GRAPH <http://togogenome.org/graph/tgup>
        {
          <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?feature_uri .
        }
        GRAPH <http://togogenome.org/graph/refseq>
        {
          VALUES ?feature_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 }

          #feature info
          ?feature_uri rdfs:subClassOf ?feature_type ;
            rdfs:label ?gene_label .

          #sequence / organism info
          ?feature_uri obo:so_part_of* ?seq .
          ?seq rdfs:subClassOf ?seq_type .
          ?refseq_link insdc:sequence ?seq ;
            insdc:definition ?seq_label ;
            insdc:sequence_version ?refseq_label ;
            insdc:sequence_version ?refseq_ver ;
            insdc:organism ?organism .
          ?feature_uri obo:RO_0002162 ?tax_link .

          #location info
          ?feature_uri insdc:location  ?insdc_location ;
            faldo:location  ?faldo .
          ?faldo faldo:begin/rdf:type ?strand_type .

          OPTIONAL { ?feature_uri insdc:gene ?gene_name }
          OPTIONAL { ?feature_uri insdc:locus_tag ?locus_tag }
        }
        GRAPH <http://togogenome.org/graph/so>
        {
          ?feature_type rdfs:label ?gene_type_label .
          ?seq_type rdfs:label ?seq_type_label .
        }
        GRAPH <http://togogenome.org/graph/faldo>
        {
          ?strand_type rdfs:subClassOf faldo:StrandedPosition ;
            rdfs:label ?strand .
        }
      }
    SPARQL

    results.map {|hash|
      hash.merge(
        :seq_length => Bio::Locations.new(hash[:insdc_location]).length
      )
    }.first
  end
end
