class GenomeCrossReferencesStanza < Stanza::Base
  property :xrefs do |tax_id|
    results = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      prefix obo: <http://purl.obolibrary.org/obo/>
      prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      prefix insdc: <http://insdc.org/owl/>
      prefix idorg: <http://rdf.identifiers.org/database/>
      prefix idtax: <http://identifiers.org/taxonomy/>

      select ?bp ?rs ?desc ?label ?xref
      from <http://togogenome.org/refseq/>
      where {
        values ?tax_id { idtax:#{tax_id} }
        values ?so { obo:SO_0000340 obo:SO_0000155 }
        ?seq rdfs:seeAlso ?tax_id .
        ?seq a ?so .
        ?seq rdfs:label ?desc .
        ?seq insdc:sequence_version ?rs .
        ?seq rdfs:seeAlso ?xref .
        ?xref rdfs:label ?label .
        ?seq rdfs:seeAlso ?xref_bp .
        ?xref_bp a idorg:BioProject .
        ?xref_bp rdfs:label ?bp .
      }
    SPARQL

    # Absolutely need cosmetic :)
    hash = results.group_by {|h1| h1[:bp]}
      .each_with_object([]) {|(k,v),a1|
        h2 = {}
        h2[:bp] = k
        h2[:data] = v.group_by {|h3|
          h3[:rs]}.each_with_object([]) {|(k,v),a2|
            h4 = {}
            h4[:rs] = k
            h4[:desc] = v.first[:desc]
            h4[:xref] = v.map {|h5|
              xref_db, xref_id = h5[:label].split(':')
              h5.merge(:xref_db => xref_db, :xref_id => xref_id)
            }.sort_by {|h6|
              h6[:xref_db]
            }
            a2 << h4
          }
        a1 << h2
        }
    hash
  end
end
