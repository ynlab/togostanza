# coding: utf-8

class ProteinSequenceAnnotationStanza < Stanza::Base
  def helpers
    ApplicationController.new.view_context
  end

  property :line_image do
    helpers.image_path('protein_sequence_annotation/line.png')
  end

  property :sequence_annotations do |tax_id, gene_id|
    annotations = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT ?parent_label ?label ?begin_location ?end_location ?seq_length ?comment (GROUP_CONCAT(?substitution, ", ") AS ?substitutions) ?seq ?feature_identifier
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?protein up:organism taxonomy:#{tax_id} ;
                   rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                   up:annotation ?annotation .

          ?annotation rdf:type ?type .
          ?type rdfs:label ?label .

          # sequence annotation 直下のtype のラベルを取得(Region, Site, Molecule Processing, Experimental Information)
          ?type rdfs:subClassOf* ?parent_type .
          ?parent_type rdfs:subClassOf up:Sequence_Annotation ;
                       rdfs:label ?parent_label .

          ?annotation up:range ?range .
          OPTIONAL { ?annotation rdfs:comment ?comment . }
          ?range up:begin ?begin_location ;
                 up:end ?end_location .

          # description の一部が取得できるが、内容の表示に必要があるのか
          OPTIONAL{
            ?annotation up:substitution ?substitution .
            ?protein up:sequence/rdf:value ?seq .
          }

          # sequence の長さ取得用
          OPTIONAL{
            ?protein up:sequence/rdf:value ?seq_txt .
            BIND (STRLEN(?seq_txt) AS ?seq_length) .
          }

          OPTIONAL {
            ?annotation rdf:type ?type . # Virtuoso 対応
            BIND (STR(?annotation) AS ?feature_identifier) .
            FILTER REGEX(STR(?annotation), 'http://purl.uniprot.org/annotation')
          }
        }
      }
      GROUP BY ?parent_label ?label ?begin_location ?end_location ?seq_length ?comment ?seq ?feature_identifier
      ORDER BY ?parent_label ?label ?begin_location ?end_location
    SPARQL

    annotations.uniq.map.with_index {|hash, i|
      begin_location, end_location, substitutions, seq = hash.values_at(:begin_location, :end_location, :substitutions, :seq)

      hash.merge(
        location_length:       length(begin_location, end_location),
        position:              position(begin_location, end_location),
        substitution_sequence: substitution_sequence(begin_location, end_location, substitutions, seq),
        row_id:                "row#{i}" #graphical view 描画用に各行の要素IDを設定
      )
    }.group_by {|hash|
      hash[:parent_label]
    }.values
  end

  private

  def position(begin_location, end_location)
    (begin_location == end_location) ? begin_location : "#{begin_location}-#{end_location}"
  end

  def length(begin_location, end_location)
    end_location.to_i - begin_location.to_i + 1
  end

  def substitution_sequence(begin_location, end_location, substitutions, seq)
    return nil unless seq

    original = seq.slice(begin_location.to_i.pred..end_location.to_i.pred)

    "#{original} → #{substitutions}: "
  end
end
