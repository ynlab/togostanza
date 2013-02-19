# coding: utf-8

class ProteinGeneralAnnotationStanza < Stanza::Base
  property :title do |tax_id, gene_id|
    "General Annotation #{tax_id}:#{gene_id}"
  end

  property :general_annotations do |tax_id, gene_id|
    annotations = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?name ?message
      WHERE {
        ?protein up:organism  taxonomy:#{tax_id} ;
                 rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                 up:annotation ?annotation .

        # up:Annotation 配下のアノテーションか up:Annotation 自身か
        # up:Annotation 自身の場合、label, type をBINDしている
        {
          ?type rdfs:subClassOf up:Annotation .
          ?annotation rdf:type ?type .
          ?type rdfs:label ?name .
        } UNION {
          BIND (up:Annotation as ?type) .
          BIND (str('Miscellaneous') as ?name) .
          ?annotation rdf:type ?type .
        } .


        # Subcellular_Location_Annotation 以外の時は、rdfs:comments を入れている
        OPTIONAL {
          FILTER (?type != up:Subcellular_Location_Annotation)
          ?annotation rdfs:comment ?message .
        }

        # Subcellular_Location_Annotation の時は、イロイロ頑張って取っている
        OPTIONAL {
          FILTER (?type = up:Subcellular_Location_Annotation)
          ?location up:alias ?message .
          ?located_in ?p ?location .
          ?annotation up:locatedIn ?located_in .
          ?annotation rdf:type up:Subcellular_Location_Annotation .
          ?protein up:annotation ?annotation .
        }
      }
    SPARQL

    # [{name: 'xxx', message: 'aaa'}, {name: 'xxx', message: 'bbb'}, {name: 'yyy', message: 'ccc'}]
    # => [{name: 'xxx', messages: ['aaa', 'bbb']}, {name: 'yyy', messages: ['ccc']}]
    annotations.group_by {|a| a[:name] }.map {|k, vs|
      {
        name:     k,
        messages: vs.map {|v| v[:message] }
      }
    }.reverse
  end
end
