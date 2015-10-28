class GenomeCrossReferencesStanza < TogoStanza::Stanza::Base
  property :xrefs do |tax_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX idtax: <http://identifiers.org/taxonomy/>

      SELECT ?bp_label ?rs ?desc ?xref ?xref_type ?label
      WHERE
      {
        VALUES ?tax_id { idtax:#{tax_id} }
        GRAPH <http://togogenome.org/graph/stats>
        {
          ?tax_id  rdfs:seeAlso/rdfs:seeAlso ?refseq .
        }
        GRAPH  <http://togogenome.org/graph/refseq>
        {
          ?refseq a insdc:Entry ;
            insdc:definition ?desc ;
            insdc:sequence_version ?rs ;
            insdc:dblink  ?bp .
          ?bp rdf:type insdc:BioProject ;
             rdfs:label ?bp_label .

          #link data
          { #BioProject
            ?refseq insdc:dblink ?xref .
            ?xref rdfs:label ?label ;
              rdf:type ?xref_type .
          }
          UNION
          { # RefSeq separated other xref, because refseq uri's rdf:label returns also description.
            ?refseq rdfs:seeAlso ?xref .
            ?xref insdc:sequence_version ?label ;
              rdf:type ?xref_type .
            FILTER (?xref_type IN (insdc:RefSeq))
          }
          UNION
          { # Other
            ?refseq rdfs:seeAlso ?xref .
            ?xref rdfs:label ?label ;
              rdf:type ?xref_type .
            FILTER (! ?xref_type IN (insdc:Entry, insdc:RefSeq))
          }
        }
      } ORDER BY ?bp_label ?refseq
    SPARQL

    results.group_by {|h| h[:bp_label] }.map do |bp, values|
      data = values.group_by {|h| h[:rs] }.map {|rs, v|
        {rs: rs, desc: v.first[:desc], xref: xref(v)}
      }
      bp = 'BioProject:' + bp
      {bp: bp, data: data}
    end
  end

  def xref(values)
    values.map {|hash|
      xref_db = hash[:xref_type].split('/').last
      xref_id = hash[:label]
      hash.merge(xref_db: xref_db, xref_id: xref_id)
    }.sort_by {|h| h[:xref_db] }
  end
end
