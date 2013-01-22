class ProteinGeneralAnnotationStanza < Stanza::Base
  property :title do |gene_id|
    "General Annotation : #{gene_id}"
  end

  # メモ:
  # とりあえず、今はslr1311 を対象にしているが、
  # Gene Id によって表示する property や投げる SPARQL が変わる?

  property :function do |gene_id|
    # メモ:
    # 全体的に言える事だけど, first するとまずいのかな...。複数件ある場合はあるのか。
    comment(gene_id, 'Function_Annotation').first
  end

  property :catalytic_activity do |gene_id|
    comment(gene_id, 'Catalytic_Activity_Annotation').first
  end

  property :cofactor do |gene_id|
    comment(gene_id, 'Cofactor_Annotation').first
  end

  property :subunit_structure do |gene_id|
    comment(gene_id, 'Subunit_Annotation').first
  end

  property :subcellular_location do |gene_id|
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

    comments = query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?alias
      FROM <http://purl.uniprot.org/uniprot/>
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        OPTIONAL {
          ?location up:alias ?alias .
          ?located_in ?p ?location .
          ?annotation up:locatedIn ?located_in .
          ?annotation rdf:type up:Subcellular_Location_Annotation .
          ?protein up:annotation ?annotation .
        }
      }
    SPARQL

    comments.first.empty? ? nil : comments
  end

  property :miscellaneous do |gene_id|
    comments = comment(gene_id, 'Annotation')
    comments.first.empty? ? nil : comments
  end


  property :sequence_similarities do |gene_id|
    comment(gene_id, 'Similarity_Annotation').first
  end

  private

  def comment(gene_id, annotation_type)
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

    query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?comment
      FROM <http://purl.uniprot.org/uniprot/>
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        OPTIONAL {
          ?annotation rdfs:comment ?comment .
          ?annotation rdf:type up:#{annotation_type} .
          ?protein up:annotation ?annotation .
        }
      }
    SPARQL
  end
end
