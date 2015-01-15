class ProteinNamesStanza < TogoStanza::Stanza::Base
  property :genes do |tax_id, gene_id|
    gene_names = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?gene_name ?synonyms_name ?locus_name ?orf_name
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein .

        # Gene names
        ?protein up:encodedBy ?gene .

        ## Name:
        OPTIONAL { ?gene skos:prefLabel ?gene_name . }

        ## Synonyms:
        OPTIONAL { ?gene skos:altLabel ?synonyms_name . }

        ## Ordered Locus Names:
        OPTIONAL { ?gene up:locusName ?locus_name . }

        ## ORF Names:
        OPTIONAL { ?gene up:orfName ?orf_name . }
      }
    SPARQL
    gene_names = gene_names.flat_map(&:to_a).group_by(&:first).each_with_object({}) {|(k, vs), hash|
      hash[k] = vs.map(&:last).uniq
    }
  end

  property :summary do |tax_id, gene_id|
    protein_summary = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?recommended_name ?ec_name ?alternative_names ?organism_name ?parent_taxonomy_names (COUNT(?parent_taxonomy) AS ?taxonomy_count)
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein_variant .
        BIND( IRI( REPLACE( STR(?protein_variant), "-\\\\d+$", "")) AS ?protein)
        ?protein a up:Protein ;
                 up:organism ?tax_id .

        # Protein names
        ## Recommended name:
        OPTIONAL {
          ?protein up:recommendedName ?recommended_name_node .
          ?recommended_name_node up:fullName ?recommended_name .
        }

        ### EC=
        OPTIONAL { ?recommended_name_node up:ecName ?ec_name . }

        OPTIONAL {
          ?protein up:alternativeName ?alternative_names_node .
          ?alternative_names_node up:fullName ?alternative_names .
        }

        # Organism
        OPTIONAL { ?tax_id up:scientificName ?organism_name . }

        # Taxonomic identifier

        # Taxonomic lineage
        OPTIONAL {
          ?tax_id rdfs:subClassOf* ?parent_taxonomy .
          ?parent_taxonomy up:scientificName ?parent_taxonomy_names .
          ?parent_taxonomy rdfs:subClassOf* ?ancestor .
        }
      }
      ORDER BY DESC(?taxonomy_count) ?alternative_names
    SPARQL

    # alternative_names, parent_taxonomy_names のみ複数取りうる
    protein_summary = protein_summary.flat_map(&:to_a).group_by(&:first).each_with_object({}) {|(k, vs), hash|
      v = vs.map(&:last).uniq
      hash[k] = [:alternative_names, :parent_taxonomy_names].include?(k) ? v : v.first
    }

    protein_summary[:taxonomy_id] = tax_id
    protein_summary[:parent_taxonomy_names].reverse! if protein_summary[:parent_taxonomy_names]
    protein_summary
  end
end
