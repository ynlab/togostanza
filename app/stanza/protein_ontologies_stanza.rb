# coding: utf-8

class ProteinOntologiesStanza < Stanza::Base
  property :title do |gene_id|
    "Protein Ontologies : #{gene_id}"
  end

  property :keywords do |gene_id|
    keywords = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?root_name ?concept ?name
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein up:reviewed true .

        ?protein ?p ?concept .
        ?concept rdf:type up:Concept .
        FILTER regex(str(?concept), 'keywords') .

        ?concept rdfs:label ?name .
        ?concept rdfs:subClassOf* ?parents .
        ?parents rdfs:label ?root_name .
        FILTER (str(?root_name) IN ('Biological process', 'Cellular component', 'Domain', 'Ligand', 'Molecular function', 'Technical term')) .
      }
      ORDER BY ?root_name ?concept ?name
    SPARQL

    # [{root_name: "hoge", concept: "x", name: "Hi"}, {root_name: "hoge", concept: "y", name: "Hello"}, {root_name: "moge", concept: "a", name: "How are you"}, {root_name: "moge", concept: "b", name: "I'm fine"}, {root_name: "moge", concept: "b", name: "Tank you."}]
    # => {hoge=>["Hi", "Hello"], :moge=>["How are you", "I'm fine, Tank you."]}
    keywords.group_by {|keyword| keyword[:root_name].gsub(/ /, '_').underscore.to_sym }.each_with_object({}) {|(k, vs), hash|
      hash[k] = vs.group_by {|keyword| keyword[:concept]}.map {|k, vs|
        vs.map {|h| h[:name] }.join(', ')
      }
    }
  end

  property :gene_ontlogies do |gene_id|

    # slr1311 の時...

    # UniProt の go の URI と UniProt のエントリの関係
    ## [{:concept=>"http://purl.uniprot.org/go/0009635"},
    ##  {:concept=>"http://purl.uniprot.org/go/0009772"},
    ##  ... ]
    up_go_uris = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?concept
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein up:reviewed true .

        ?protein ?p ?concept .
        ?concept rdf:type up:Concept .
        FILTER regex(str(?concept), 'go') .
      }
    SPARQL

    # OBO の go の URI と UniProt の go の URI の関係
    ## "{ BIND(<http://purl.uniprot.org/go/0009635> as ?up_go_uri) }
    ##  UNION { BIND(<http://purl.uniprot.org/go/0009772> as ?up_go_uri) }
    ##  ... "
    bind_up_go_uri = up_go_uris.flat_map {|go|
      "{ BIND(<#{go[:concept]}> as ?up_go_uri) }"
    }.join(' UNION ')

    ## [{:obo_go_uri=>"http://purl.obolibrary.org/obo/GO_0009635"},
    ##  {:obo_go_uri=>"http://purl.obolibrary.org/obo/GO_0009772"},
    ## ...]
    obo_go_uris = query(:togogenome, <<-SPARQL)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT DISTINCT ?obo_go_uri
      WHERE {
        #{bind_up_go_uri}
        ?up_go_uri rdfs:seeAlso ?obo_go_uri .
      }
    SPARQL

    # OBO の go の階層とラベル
    ## "{ BIND(<http://purl.obolibrary.org/obo/GO_0009635> as ?obo_go_uri) }
    ##  UNION { BIND(<http://purl.obolibrary.org/obo/GO_0009772> as ?obo_go_uri) }
    ##  ... "
    bind_obo_go_uri = obo_go_uris.flat_map {|uri|
      "{ BIND(<#{uri[:obo_go_uri]}> as ?obo_go_uri) }"
    }.join(' UNION ')

    ## [{:root_name=>"biological_process", :name=>"response to herbicide"},
    ##  {:root_name=>"biological_process", :name=>"photosynthetic electron transport in photosystem II"},
    ##  {:root_name=>"molecular_function", :name=>"oxidoreductase activity"},
    ##  ...]
    gene_ontlogies = query(:go, <<-SPARQL)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT DISTINCT ?name ?root_name
      WHERE {
        #{bind_obo_go_uri}
        ?obo_go_uri rdfs:label ?name .
        # comment は無い?
        # cf) http://lod.dbcls.jp/openrdf-workbench5l/repositories/go/explore?resource=obo%3AGO_0009635
        #?obo_go_uri rdfs:comment ?comment .

        ?obo_go_uri rdfs:subClassOf* ?parents .
        ?parents rdfs:label ?root_name .
        FILTER (str(?root_name) IN ('biological_process', 'cellular_component', 'molecular_function')) .
      }
    SPARQL

    gene_ontlogies.group_by {|go| go[:root_name].to_sym }
  end
end
