class OrganismJbrowseStanza < TogoStanza::Stanza::Base
  property :select_tax_id do |tax_id|
    results = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT ?seq
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
      WHERE
      {
        VALUES ?seq_type  { obo:SO_0000340 obo:SO_0000155 }

        ?seq rdfs:seeAlso taxid:#{tax_id} ;
            rdf:type ?seq_type .
      }
    SPARQL

    if results.length > 0 then
      select_tax_id = tax_id
    else
      select_tax_id = nil
    end
    select_tax_id
  end
end
