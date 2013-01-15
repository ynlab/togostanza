class ProtainNamesAndOriginStanza < StanzaBase
  property :summary do |gene_id|
    solutions = query(:uniprot, <<-SPARQL)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

      SELECT DISTINCT ?recommended_name ?ec_name ?alternative_names ?encoded_by ?gene_names ?synonyms_name ?locus_name ?organism_name ?taxonomic_identifier ?parent_taxonomy_name
      WHERE {
        ?target up:locusName "#{gene_id}" .
        ?id up:encodedBy ?target .

        # Protein names
        ## Recommended name:
        ?id up:recommendedName ?recommended_name_node .
        ?recommended_name_node up:fullName ?recommended_name .
        ### EC=
        ?recommended_name_node up:ecName ?ec_name .

        ## Alternative name(s):
        ?id up:alternativeName ?alternative_names_node .
        ?alternative_names_node up:fullName ?alternative_names .

        # Gene names
        ?id up:encodedBy ?encoded_by .
        ## Name:
        ?encoded_by skos:prefLabel ?gene_names .
        ## Synonyms:
        ?encoded_by skos:altLabel ?synonyms_name .
        ## Ordered Locus Names:
        ?encoded_by up:locusName ?locus_name .

        # Organism
        ?id up:organism ?taxonomy_id .

        ?taxonomy_id up:scientificName ?organism_name .

        # Taxonomic identifier
        ?id up:organism ?taxonomic_identifier .

        # Taxonomic lineage
        ?taxonomy_id rdfs:subClassOf* ?parent_taxonomy .
        ?parent_taxonomy up:scientificName ?parent_taxonomy_name .
      }
    SPARQL

    # [{a: 'hoge', b: 'moge'}, {a: 'hoge', b: 'fuga'}] => {a: ['hoge'], b: ['moge', 'fuga']}
    solutions.inject({}) {|new_hash, old_hash|
      old_hash.each {|k, v|
        (new_hash[k] ||= []) << v.to_s unless new_hash[k] && new_hash[k].include?(v.to_s)
      }
      new_hash
    }
  end
end
