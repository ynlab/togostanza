class GenomeJbrowseStanza < TogoStanza::Stanza::Base
  property :select_tax_id do |tax_id, gene_id|
    if tax_id.nil? then
      results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
        DEFINE sql:select-option "order"
        PREFIX obo: <http://purl.obolibrary.org/obo/>
        PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/sequence#>

        SELECT DISTINCT (REPLACE(STR(?taxonomy),"http://identifiers.org/taxonomy/","") AS ?tax_id)
        FROM <http://togogenome.org/graph/refseq/>
        FROM <http://togogenome.org/graph/so/>
        WHERE
        {
          VALUES ?locus_tag { "#{ gene_id }" }
          VALUES ?seq_type  { obo:SO_0000340 obo:SO_0000155 }

          ?gene insdc:locus_tag ?locus_tag ;
            a ?gene_type ;
            obo:so_part_of ?seq .
          ?seq rdf:type ?seq_type ;
            rdfs:seeAlso ?taxonomy .
          ?taxonomy a <http://identifiers.org/taxonomy/> .
        }
      SPARQL

      if results.length == 1 then
        select_tax_id = results.first[:tax_id]
      else
        select_tax_id = nil
      end
    else
      select_tax_id = tax_id
    end
  end

  property :display_range do |tax_id, gene_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/sequence#>

      SELECT DISTINCT (REPLACE(STR(?refseq),"http://identifiers.org/refseq/","") AS ?seq_label) ?start ?end ?seq_length
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
      FROM <http://togogenome.org/graph/faldo/>
      WHERE
      {
        VALUES ?locus_tag { "#{ gene_id }" }
        VALUES ?seq_type  { obo:SO_0000340 obo:SO_0000155 }
        VALUES ?gene_type { obo:SO_0000704 obo:SO_0000252 obo:SO_0000253 }
        VALUES ?faldo_stand_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition }

        #gene
        ?gene insdc:locus_tag ?locus_tag ;
          a ?gene_type ;
          obo:so_part_of ?seq .

        #position
        ?gene faldo:location ?faldo .
        ?faldo faldo:begin/faldo:position ?start .
        ?faldo faldo:end/faldo:position ?end .

        #sequence
        ?seq rdfs:seeAlso ?refseq ;
          a ?seq_type ;
         insdc:sequence_length ?seq_length.
        ?refseq a <http://identifiers.org/refseq/> .
      }
    SPARQL

    start_pos = results.first[:start].to_i
    end_pos = results.first[:end].to_i
    gene_length = (end_pos - start_pos).abs + 1
    display_start_pos = [1, start_pos - (gene_length*5)].max
    display_end_pos = [end_pos + (gene_length*5), results.first[:seq_length].to_i].min
    display_range = {:ref => results.first[:seq_label], :disp_start => display_start_pos, :disp_end => display_end_pos }
  end
end
