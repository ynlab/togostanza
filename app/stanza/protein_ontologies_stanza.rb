# coding: utf-8

class ProteinOntologiesStanza < Stanza::Base
  property :title do |tax_id, gene_id|
    "Ontologies #{tax_id}:#{gene_id}"
  end

  property :keywords do |tax_id, gene_id|
    keywords = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?root_name ?concept (GROUP_CONCAT(DISTINCT ?name; SEPARATOR=", ") AS ?names)
      WHERE {
        ?protein up:organism  taxonomy:#{tax_id} ;
                 rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

        ?protein ?p ?concept .
        ?concept rdf:type up:Concept .
        FILTER regex(str(?concept), 'keywords') .

        ?concept rdfs:label ?name .
        ?concept rdfs:subClassOf* ?parents .
        ?parents rdfs:label ?root_name .
        FILTER (str(?root_name) IN ('Biological process', 'Cellular component', 'Domain', 'Ligand', 'Molecular function', 'Technical term')) .
      }
      GROUP BY ?root_name ?concept
      ORDER BY ?root_name ?concept ?name
    SPARQL

    keywords.group_by {|keyword|
      keyword[:root_name].gsub(/ /, '_').underscore
    }
  end

  property :gene_ontlogies do |tax_id, gene_id|

    # slr1311 の時...

    # UniProt の go の URI と UniProt のエントリの関係
    ## [{:concept=>"http://purl.uniprot.org/go/0009635"},
    ##  {:concept=>"http://purl.uniprot.org/go/0009772"},
    ##  ... ]
    up_go_uris = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?concept
      WHERE {
        ?protein up:organism  taxonomy:#{tax_id} ;
                 rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

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

    gene_ontlogies.group_by {|go| go[:root_name] }
  end
end
