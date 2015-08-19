require 'net/http'
require 'uri'

class NucleotideSequenceStanza < TogoStanza::Stanza::Base
  property :nucleotide_sequences do |tax_id, gene_id|
    results = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo:    <http://purl.obolibrary.org/obo/>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

      SELECT DISTINCT ?nuc_seq_pos
      WHERE
      {
        {
          SELECT ?feature_uri
          {
            GRAPH <http://togogenome.org/graph/tgup>
            {
              <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?feature_uri .
            }
          } ORDER BY ?feature_uri LIMIT 1
        }
        GRAPH <http://togogenome.org/graph/refseq>
        {
          VALUES ?feature_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 }
          ?feature_uri rdfs:subClassOf ?feature_type ;
            insdc:location  ?insdc_location ;
            obo:so_part_of/^insdc:sequence/insdc:sequence_version ?refseq_ver  .
          BIND (CONCAT("http://togows.dbcls.jp/entry/nucleotide/", ?refseq_ver,"/seq/", ?insdc_location) AS ?nuc_seq_pos)
        }
      }
    SPARQL
    results.map {|hash|
      hash.merge(
        :value => get_sequence_from_togows(hash[:nuc_seq_pos]).upcase
      )
    }.first
  end

  #Returns sequence characters from the TogoWS API.
  def get_sequence_from_togows(togows_url)
    url = URI.parse(togows_url)
    path = Net::HTTP::Get.new(url.path)
    Net::HTTP.start(url.host, url.port) {|http|
      res = http.request(path)
      res.body
    }
  end
end
