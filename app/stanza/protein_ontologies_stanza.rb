# coding: utf-8

class ProteinOntologiesStanza < Stanza::Base
  property :keywords do |tax_id, gene_id|
    keywords = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct: <http://purl.org/dc/terms/>

      SELECT ?root_name ?concept (GROUP_CONCAT(?name, ', ') AS ?names) {
        SELECT DISTINCT ?root_name ?concept ?name
        WHERE {
          GRAPH <http://togogenome.org/graph/> {
            <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
          }

          GRAPH ?g {
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
        }
        GROUP BY ?root_name ?concept
        ORDER BY ?root_name ?concept ?name
      }
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
    up_go_uris = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct: <http://purl.org/dc/terms/>

      SELECT DISTINCT ?concept
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?protein up:organism  taxonomy:#{tax_id} ;
                   rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

          ?protein ?p ?concept .
          ?concept rdf:type up:Concept .
          FILTER regex(str(?concept), 'go') .
        }
      }
    SPARQL

    next if up_go_uris.empty?

    # OBO の go の URI を UniProt の go の URI へ変換
    obo_go_uris = up_go_uris.map {|e| {obo_go_uri: e[:concept].gsub("http://purl.uniprot.org/go/", "http://purl.obolibrary.org/obo/GO_")} }

    next if obo_go_uris.empty?

    # OBO の go の階層とラベル
    # "<http://purl.obolibrary.org/obo/GO_0009635>, <http://purl.obolibrary.org/obo/GO_0009772>, ..."
    obo_go_uri_values = obo_go_uris.flat_map {|uri|
      "<#{uri[:obo_go_uri]}>"
    }.join(', ')

    ## [{:root_name=>"biological_process", :name=>"response to herbicide"},
    ##  {:root_name=>"biological_process", :name=>"photosynthetic electron transport in photosystem II"},
    ##  {:root_name=>"molecular_function", :name=>"oxidoreductase activity"},
    ##  ...]
    gene_ontlogies = query(:go, <<-SPARQL.strip_heredoc)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX dct: <http://purl.org/dc/terms/>

      SELECT DISTINCT ?name ?root_name ?obo_go_uri
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/go/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?obo_go_uri rdfs:label ?name .
          # comment は無い?
          # cf) http://lod.dbcls.jp/openrdf-workbench5l/repositories/go/explore?resource=obo%3AGO_0009635
          #?obo_go_uri rdfs:comment ?comment .

          ?obo_go_uri rdfs:subClassOf* ?parents .
          ?parents rdfs:label ?root_name .
          FILTER (str(?root_name) IN ('biological_process', 'cellular_component', 'molecular_function')) .
          FILTER (?obo_go_uri in (#{obo_go_uri_values})) .
        }
      }
    SPARQL

    gene_ontlogies.map {|hash|
      hash.merge(url: hash[:obo_go_uri].gsub(/http:\/\/purl\.obolibrary\.org\/obo\/GO_/, 'http://www.ebi.ac.uk/QuickGO/GTerm?id=GO:'))
    }.group_by {|go| go[:root_name] }
  end
end
