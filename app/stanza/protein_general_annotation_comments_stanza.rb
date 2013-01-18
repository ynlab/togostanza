class ProteinGeneralAnnotationCommentsStanza < StanzaBase
  property :title, 'General Annotation'

  # メモ:
  # とりあえず、今はslr1311 を対象にしているが、
  # Gene Id によって表示する property や投げる SPARQL が変わる?

  property :function do |gene_id|
    # メモ:
    # 全体的に言える事だけど, first するとまずいのかな...。複数件ある場合はあるのか。
    query(:uniprot, select_comment(gene_id, 'Function_Annotation')).first
  end

  property :catalytic_activity do |gene_id|
    query(:uniprot, select_comment(gene_id, 'Catalytic_Activity_Annotation')).first
  end

  property :cofactor do |gene_id|
    query(:uniprot, select_comment(gene_id, 'Cofactor_Annotation')).first
  end

  property :subunit_structure do |gene_id|
    query(:uniprot, select_comment(gene_id, 'Subunit_Annotation')).first
  end

  property :subcellular_location do |gene_id|
    query(:uniprot, <<-SPARQL)
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?alias
      FROM <http://purl.uniprot.org/uniprot/>
      WHERE {
        ?target up:locusName "#{gene_id}" .
        ?id up:encodedBy ?target .

        ?location up:alias ?alias .
        ?located_in ?p ?location .
        ?annotation up:locatedIn ?located_in .
        ?annotation rdf:type up:Subcellular_Location_Annotation .
        ?id up:annotation ?annotation .
      }
    SPARQL
  end

  property :miscellaneous do |gene_id|
    query(:uniprot, select_comment(gene_id, 'Annotation'))
  end


  property :sequence_similarities do |gene_id|
    query(:uniprot, select_comment(gene_id, 'Similarity_Annotation')).first
  end

  private

  def select_comment(gene_id, annotation_type)
    <<-SPARQL
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?comment
      FROM <http://purl.uniprot.org/uniprot/>
      WHERE {
        ?target up:locusName "#{gene_id}" .
        ?id up:encodedBy ?target .

        ?annotation rdfs:comment ?comment .
        ?annotation rdf:type up:#{annotation_type} .
        ?id up:annotation ?annotation .
      }
    SPARQL
  end
end
