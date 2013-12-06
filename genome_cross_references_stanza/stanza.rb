class GenomeCrossReferencesStanza < TogoStanza::Stanza::Base
  property :xrefs do |tax_id|
    results = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/sequence#>
      PREFIX idorg: <http://rdf.identifiers.org/database/>
      PREFIX idtax: <http://identifiers.org/taxonomy/>

      SELECT ?bp ?rs ?desc ?label ?xref
      FROM <http://togogenome.org/graph/refseq/>
      WHERE {
        VALUES ?tax_id { idtax:#{tax_id} }
        VALUES ?so { obo:SO_0000340 obo:SO_0000155 }
        ?seq rdfs:seeAlso ?tax_id .
        ?seq a ?so .
        ?seq rdfs:label ?desc .
        ?seq insdc:sequence_version ?rs .
        ?seq rdfs:seeAlso ?xref .
        ?xref rdfs:label ?label .
        ?seq rdfs:seeAlso ?xref_bp .
        ?xref_bp a <http://identifiers.org/bioproject/> .
        ?xref_bp rdfs:label ?bp .
      }
    SPARQL

    results.group_by {|h| h[:bp] }.map do |bp, values|
      data = values.group_by {|h| h[:rs] }.map {|rs, v|
        {rs: rs, desc: v.first[:desc], xref: xref(v)}
      }

      {bp: bp, data: data}
    end
  end

  def xref(values)
    values.map {|hash|
      xref_db, xref_id = hash[:label].split(':')
      hash.merge(xref_db: xref_db, xref_id: xref_id)
    }.sort_by {|h| h[:xref_db] }
  end
end
