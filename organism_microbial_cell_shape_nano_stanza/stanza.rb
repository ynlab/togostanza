class OrganismMicrobialCellShapeNanoStanza < TogoStanza::Stanza::Base
  property :cell_shapes do |tax_id|
    result = query("http://togostanza.org/sparql", <<-SPARQL.strip_heredoc).first
      DEFINE sql:select-option "order"

      PREFIX mpo: <http://purl.jp/bio/01/mpo#>
      PREFIX tax: <http://identifiers.org/taxonomy/>

      SELECT ?label ?file_name
      FROM <http://togogenome.org/graph/gold/>
      FROM <http://togogenome.org/graph/mpo/>
      WHERE {
        VALUES ?arrange_label {
          "Tetrad"@en "Diplococcus"@en "Diplobacillus"@en "Streptococcus"@en
          "Streptobacillus"@en "Staphylococcus"@en "Single"@en
        }
        ?arrange rdfs:label ?arrange_label .
        tax:#{tax_id} mpo:MPO_10016 ?arrange .
        BIND (concat("arrangement_", lcase(?arrange_label), ".svg") AS ?arrange_file_name)

        VALUES ?shape_label { "Rod"@en "Coccus"@en }
        tax:#{tax_id} mpo:MPO_10001 ?shape .
        ?shape rdfs:label ?shape_label .

        BIND (IF (str(?shape_label) = "Rod", "Bacillus", ?shape_label) AS ?single_label)
        BIND (concat("arrangement_", lcase(?single_label), ".svg") AS ?shape_file_name)

        # arrange を使うか、 shape を使うかここで判断
        BIND (IF (str(?arrange_label) = "Single", ?shape_file_name, ?arrange_file_name) AS ?file_name)
        BIND (IF (str(?arrange_label) = "Single", ?shape_label, ?arrange_label) AS ?label)
      }
    SPARQL

    if result
      result[:image_url] = "/stanza/assets/organism_microbial_cell_shape_nano/#{result[:file_name]}"
      result
    else
      nil
    end
  end
end
