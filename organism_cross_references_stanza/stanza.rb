class OrganismCrossReferencesStanza < TogoStanza::Stanza::Base
  property :link_list do |tax_id|
    link_list1 = query(:togogenome, <<-SPARQL.strip_heredoc)
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX insdc: <http://insdc.org/owl/>
      PREFIX idtax: <http://identifiers.org/taxonomy/>

      SELECT ?label ?link
      FROM <http://togogenome.org/graph/gold/>
      FROM <http://togogenome.org/graph/refseq/>
      WHERE
      {
        {
          SELECT REPLACE(str(?gold),"http://www.genomesonline.org/cgi-bin/GOLD/GOLDCards.cgi\\\\?goldstamp=", "GOLD:" ) as ?label ?gold as ?link
          FROM <http://togogenome.org/gold/>
          WHERE
          {
            ?gold mccv:MCCV_000020 idtax:#{tax_id} .
          }
        }
        UNION
        {
          SELECT DISTINCT ?label ?xref as ?link
          FROM <http://togogenome.org/graph/refseq/>
          WHERE
          {
            values ?tax_id { idtax:#{tax_id} }
            values ?so { obo:SO_0000340 obo:SO_0000155 }
            ?seq rdfs:seeAlso ?tax_id .
            ?seq a ?so .
            ?seq rdfs:seeAlso ?xref .
            ?xref rdfs:label ?label .
          } ORDER BY ?label
        }
      }
    SPARQL

    #TODO query for other endpoints.

    link_list1.map {|hash|
      # temporary replace. identifiers.org's links are not available.
      hash[:link].gsub!('http://identifiers.org/bioproject/', 'http://www.ncbi.nlm.nih.gov/bioproject/?term=')
      hash[:link].gsub!('http://identifiers.org/ncbigi/', 'http://www.ncbi.nlm.nih.gov/nuccore/')

      xref_db, xref_id = hash[:label].split(':')
      hash.merge(:xref_db => xref_db, :xref_id => xref_id)
    }.group_by{|hash| hash[:xref_db] }.map {|hash|
      hash.last.last.merge!(:is_last_data => true) #flag for separator character
      hash.last
    }

  end
end
