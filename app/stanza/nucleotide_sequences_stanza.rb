require 'net/http'
require 'uri'

class NucleotideSequencesStanza < Stanza::Base
  property :nucleotide_sequences do |tax_id, gene_id|
    results = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo:    <http://purl.obolibrary.org/obo/>
      PREFIX faldo:  <http://biohackathon.org/resource/faldo#>
      PREFIX idorg:  <http://rdf.identifiers.org/database/>
      PREFIX insdc:  <http://insdc.org/owl/>

      SELECT distinct ?locus_tag
        concat("http://togows.dbcls.jp/entry/nucleotide/", replace(?refseq_label,"RefSeq:",""),"/seq/", ?insdc_location) as ?nuc_seq_pos
      FROM <http://togogenome.org/refseq/>
      FROM <http://togogenome.org/so/>
      WHERE
      {
        values ?locus_tag { "#{gene_id}" }
        values ?seq_type  { obo:SO_0000340 obo:SO_0000155 }
        values ?gene_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 }

        ?gene insdc:feature_locus_tag ?locus_tag ;
          a ?gene_type ;
          obo:so_part_of ?seq .
        ?seq a ?seq_type ;
          rdfs:seeAlso ?refseq .
        ?refseq a idorg:RefSeq ;
          rdfs:label ?refseq_label .
        ?gene faldo:location ?faldo .
        ?faldo insdc:location ?insdc_location .
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
