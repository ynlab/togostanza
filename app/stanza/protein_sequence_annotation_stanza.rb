# coding: utf-8

class ProteinSequenceAnnotationStanza < Stanza::Base
  property :title do |gene_id|
    "Sequence annotation : #{gene_id}"
  end

  property :sequence_annotations do |gene_id|
    annotations = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?parent_label ?label ?begin_location ?end_location ?comment ?substitution ?annotation
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                 up:reviewed true ;
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
        # OPTIONAL{ ?annotation up:substitution ?substitution . }
      } ORDER BY ?parent_label ?label ?begin_location ?end_location
    SPARQL

    annotations.map {|hash|
      hash.merge(
        location_length: length(hash[:begin_location], hash[:end_location]),
        position: position(hash[:begin_location], hash[:end_location]),
        feature_identifier: (hash[:annotation] if hash[:annotation].include?('http://purl.uniprot.org/annotation/'))
      )
    }.group_by {|hash|
      hash[:parent_label].gsub(/ /, '_').underscore
    }
  end

  private
  def position(begin_location, end_location)
    (begin_location == end_location) ? begin_location : "#{begin_location}-#{end_location}"
  end

  def length(begin_location, end_location)
    end_location.to_i - begin_location.to_i + 1
  end
end
