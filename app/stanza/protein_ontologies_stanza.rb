# coding: utf-8

class ProteinOntologiesStanza < StanzaBase
  property :title do |gene_id|
    "Protein Ontologies : #{gene_id}"
  end

  property :gene_ontlogies do |gene_id|
    uniprot_url = query(:togogenome, <<-SPARQL).first[:up]
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>

      SELECT ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{gene_id}" .
        ?s rdfs:seeAlso ?np .
        ?np rdf:type insdc:Protein .
        ?np rdfs:seeAlso ?up .
      }
    SPARQL

    gene_ontlogies = query(:uniprot_origin, <<-SPARQL)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?concept ?name ?comment ?root
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        ?protein ?p ?concept .
        ?concept rdf:type up:Concept .
        FILTER regex(str(?concept), 'go') .

        ?concept rdfs:label ?name .
        ?concept rdfs:comment ?comment .

        # 先祖を探し、元が3つのどこに含まれるかを調べている
        ?concept rdfs:subClassOf* ?p_concept .
        ?p_concept rdfs:label ?root .
        FILTER (str(?root) IN ('biological process', 'cellular component', 'molecular function')) .
      }
    SPARQL

    # root ごとに分割し、それぞれを concept で分割した結果を入れている
    # [{root: 'xxx', concept: '111', c: 'hoge' }, {root: 'xxx', concept: '111', c: 'moge'}, {root: 'xxx', concept: '222', c: 'fuga'}, {root: 'yyy', concept: '999', c: 'piyo'}]
    # => {xxx: [{root: 'xxx', concept: '111', c: 'hoge'}, {root: 'xxx', concept: '222', c:fuga}], yyy: [{root: 'yyy', concept: '999', c: 'piyo'}]}
    gene_ontlogies.group_by {|go| go[:root] }.each_with_object({}) {|(root, go_group_by_root), hash|
      hash[root.gsub(/ /, '_').to_sym] = go_group_by_root.group_by {|go| go[:concept]}.map {|concept, go_group_by_concept|
        # 同じ concept の場合、今は最初の方を入れている
        go_group_by_concept.first
      }
    }
  end
end
