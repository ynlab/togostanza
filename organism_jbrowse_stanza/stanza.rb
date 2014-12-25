class OrganismJbrowseStanza < TogoStanza::Stanza::Base
  property :sequence_version do |tax_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>
      PREFIX ddbj: <http://ddbj.nig.ac.jp/ontologies/sequence#>

      SELECT ?version ?length
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
      WHERE
      {
        VALUES ?seq_type  { obo:SO_0000340 obo:SO_0000155 }

        ?seq rdfs:seeAlso taxid:#{tax_id} ;
          rdf:type ?seq_type ;
          ddbj:sequence_length ?length ;
          ddbj:sequence_version ?version .
      } ORDER BY DESC(?length) LIMIT 1
    SPARQL

    if results.length > 0 then
      display_start_pos = 1
      display_end_pos = [ results.first[:length].to_i, 200000 ].min
      sequence_version = {:tax_id => tax_id, :ref => results.first[:version], :display_end_pos => display_start_pos, :display_end_pos => display_end_pos}
    else
      sequence_version = {:tax_id => nil}
    end
    sequence_version
  end
end
