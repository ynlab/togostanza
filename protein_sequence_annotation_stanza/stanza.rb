class ProteinSequenceAnnotationStanza < TogoStanza::Stanza::Base
  property :sequence_annotations do |tax_id, gene_id|
    annotations = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>

      SELECT DISTINCT ?parent_label ?label ?begin_location ?end_location ?seq_length ?comment (GROUP_CONCAT(?substitution, ", ") AS ?substitutions) ?seq ?feature_identifier
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        {
          SELECT ?gene
          {
            <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene .
          } ORDER BY ?gene LIMIT 1
        }
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> skos:exactMatch ?gene ;
          rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:annotation ?annotation .

        ?annotation rdf:type ?type .
        ?type rdfs:label ?label .

        # sequence annotation 直下のtype のラベルを取得(Region, Site, Molecule Processing, Experimental Information)
        ?type rdfs:subClassOf* ?parent_type .
        ?parent_type rdfs:subClassOf up:Sequence_Annotation ;
                     rdfs:label ?parent_label .

        ?annotation up:range ?range .
        OPTIONAL { ?annotation rdfs:comment ?comment . }
        ?range faldo:begin/faldo:position ?begin_location ;
               faldo:end/faldo:position ?end_location .


        # 互いに isoform なUniprotがあるので (e.g. P42166, P42167) 同じIDの isoform で配列のあるものに絞る
        ?protein up:sequence ?isoform .
        BIND( REPLACE( STR(?protein), "http://purl.uniprot.org/uniprot/", "") AS ?up_id)
        FILTER( REGEX(?isoform, ?up_id))
        ?isoform rdf:value ?value .

        # description の一部が取得できるが、内容の表示に必要があるのか
        OPTIONAL {
          ?annotation up:substitution ?substitution . 
          ?isoform rdf:value ?seq .
        }

        # sequence の長さ取得
        OPTIONAL {
          ?isoform rdf:value ?seq_txt .
          BIND (STRLEN(?seq_txt) AS ?seq_length) .
        }

        OPTIONAL {
          ?annotation rdf:type ?type . # Virtuoso 対応
          BIND (STR(?annotation) AS ?feature_identifier) .
          FILTER REGEX(STR(?annotation), 'http://purl.uniprot.org/annotation')
        }
      }
      GROUP BY ?parent_label ?label ?begin_location ?end_location ?seq_length ?comment ?seq ?feature_identifier
      ORDER BY ?parent_label ?label ?begin_location ?end_location
    SPARQL

    annotations.uniq.map.with_index {|hash, i|
      begin_location, end_location, substitutions, seq = hash.values_at(:begin_location, :end_location, :substitutions, :seq)

      hash.merge(
        location_length:       length(begin_location, end_location),
        position:              position(begin_location, end_location),
        substitution_sequence: substitution_sequence(begin_location, end_location, substitutions, seq),
        row_id:                "row#{i}" #graphical view 描画用に各行の要素IDを設定
      )
    }.group_by {|hash|
      hash[:parent_label]
    }.values
  end

  private

  def position(begin_location, end_location)
    (begin_location == end_location) ? begin_location : "#{begin_location}-#{end_location}"
  end

  def length(begin_location, end_location)
    end_location.to_i - begin_location.to_i + 1
  end

  def substitution_sequence(begin_location, end_location, substitutions, seq)
    return nil unless seq

    original = seq.slice(begin_location.to_i.pred..end_location.to_i.pred)

    "#{original} → #{substitutions}: "
  end
end
