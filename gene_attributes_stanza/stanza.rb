require 'net/http'
require 'uri'

class GeneAttributesStanza < TogoStanza::Stanza::Base
  property :gene_attributes do |tax_id, gene_id|
    results = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      PREFIX insdc:  <http://ddbj.nig.ac.jp/ontologies/sequence#>

      SELECT DISTINCT ?locus_tag ?gene_type_label ?seq_label ?seq_type_label ?gene_symbol
        (REPLACE(?refseq_label,"RefSeq:","") AS ?refseq_label) ?organism ?taxid
        ?faldo_begin_position ?faldo_end_position ?stand ?insdc_location
        (CONCAT("http://togows.dbcls.jp/entry/nucleotide/", REPLACE(?refseq_label,"RefSeq:",""),"/seq/", ?insdc_location) AS ?seqence)
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
      FROM <http://togogenome.org/graph/faldo/>
      {
        {
          SELECT DISTINCT ?gene ?locus_tag ?gene_type_label ?seq_label ?seq_type_label
            ?refseq_label ?organism ?taxid
            ?faldo_begin_position ?faldo_end_position ?stand ?insdc_location
          WHERE
          {
            VALUES ?locus_tag { "#{ gene_id }" }
            VALUES ?seq_type  { obo:SO_0000340 obo:SO_0000155 }
            VALUES ?gene_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 }
            VALUES ?faldo_stand_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition }

            ?gene ?p ?locus_tag ;
              a ?gene_type ;
              obo:so_part_of ?seq .
            ?gene_type rdfs:label ?gene_type_label .

            #sequence
            ?seq rdfs:label ?seq_label ;
              a ?seq_type ;
              rdfs:seeAlso ?refseq ;
              insdc:organism ?organism ;
              rdfs:seeAlso ?taxonomy .
            ?seq_type rdfs:label ?seq_type_label .
            ?refseq a <http://identifiers.org/refseq/> ;
              rdfs:label ?refseq_label .
            ?taxonomy a <http://identifiers.org/taxonomy/> ;
              rdfs:label ?taxid .

            #faldo
            ?gene faldo:location ?faldo .
            ?faldo insdc:location ?insdc_location ;
              faldo:begin ?faldo_begin ;
              faldo:end ?faldo_end .
            ?faldo_begin faldo:position ?faldo_begin_position ;
              rdf:type ?faldo_stand_type .
            ?faldo_end faldo:position ?faldo_end_position .
            ?faldo_stand_type rdfs:label ?stand .
          }
        }
        OPTIONAL { ?gene insdc:gene ?gene_symbol. }
      }
    SPARQL

    results.map {|hash|
      hash.merge(
        :refseq_link => "http://identifiers.org/refseq/" + hash[:refseq_label].split(':').last,
        :tax_link => "http://identifiers.org/taxonomy/" + hash[:taxid].split(':').last,
        :seq_length => sequence_length(hash[:insdc_location])
      )
    }.first
  end

  def sequence_length(insdc_location)
    if insdc_location.start_with?('join') then
      positions = (insdc_location[5..(insdc_location.length) -2]).split(',')
      length = 0
      positions.each {|i|
        length += sequence_length_from_pos_text(i)
      }
      length
    else
      sequence_length_from_pos_text(insdc_location)
    end
  end

  def sequence_length_from_pos_text(pos_text)
    pos = pos_text.split('..')
    (pos[1].to_i - pos[0].to_i).abs + 1
  end
end
