class ProteinGeneralAnnotationStanza < TogoStanza::Stanza::Base
  property :general_annotations do |tax_id, gene_id|

    result = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
    PREFIX up: <http://purl.uniprot.org/core/>
    PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

    SELECT DISTINCT ?name ?message
    FROM <http://togogenome.org/graph/uniprot>
    FROM <http://togogenome.org/graph/tgup>
    WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:annotation ?annotation .

        {
            # type がup:Annotation のアノテーション

            ?annotation rdf:type up:Annotation .

            # name, message の取得
            BIND(STR('Miscellaneous') AS ?name) .
            ?annotation rdfs:comment ?message .

        }UNION{
            # subClassOf Annotation で type が up:Subcellular_Location_Annotation のアノテーション

            ?type rdfs:subClassOf up:Annotation .
            ?annotation rdf:type up:Subcellular_Location_Annotation .

            # name, message の取得
            up:Subcellular_Location_Annotation rdfs:label ?name .
            ?annotation up:locatedIn ?located_in .
            ?located_in ?p ?location .
            ?location up:alias ?message .

        }UNION{
            # type が up:Subcellular_Location_Annotation 以外の subClassOf Annotation のアノテーション
 
            ?annotation rdf:type ?type .
            ?type rdfs:subClassOf up:Annotation .
            FILTER (?type != up:Subcellular_Location_Annotation)

            # name, message の取得
            ?type rdfs:label ?name .
            ?annotation rdfs:comment ?message .

        }
    }
    SPARQL

    # [{name: 'xxx', message: 'aaa'}, {name: 'xxx', message: 'bbb'}, {name: 'yyy', message: 'ccc'}]
    # => [{name: 'xxx', messages: ['aaa', 'bbb']}, {name: 'yyy', messages: ['ccc']}]
    result.group_by {|a| a[:name] }.map {|k, vs|
      {
        name:     k,
        messages: vs.map {|v| v[:message] }
      }
    }.reverse
  end
end
