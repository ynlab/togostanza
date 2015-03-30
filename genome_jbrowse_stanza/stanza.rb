class GenomeJbrowseStanza < TogoStanza::Stanza::Base
  property :select_tax_id do |refseq_id, gene_id|
    results = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>

      SELECT DISTINCT (REPLACE(STR(?taxonomy),"http://identifiers.org/taxonomy/","") AS ?tax_id)
      WHERE
      {
        GRAPH <http://togogenome.org/graph/tgup>
        {
          <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> skos:exactMatch ?feature_uri .
        }
        GRAPH <http://togogenome.org/graph/refseq>
        {
           ?feature_uri  obo:RO_0002162 ?taxonomy
        }
      }
    SPARQL

    if results.length == 1 then
      select_tax_id = results.first[:tax_id]
    else
      select_tax_id = nil
    end
  end

  property :display_range do |refseq_id, gene_id|
    results = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>

      SELECT ?seq_label ?start ?end ?seq_length
      WHERE
      {
        GRAPH <http://togogenome.org/graph/tgup>
        {
          <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> skos:exactMatch ?feature_uri .
        }
        GRAPH <http://togogenome.org/graph/refseq>
        {
          ?feature_uri insdc:location  ?insdc_location ;
            faldo:location  ?faldo .
          ?faldo faldo:begin/faldo:position ?start .
          ?faldo faldo:end/faldo:position ?end . 

          ?feature_uri obo:so_part_of* ?seq .
          ?refseq insdc:sequence ?seq ;
            insdc:sequence_version ?seq_label .
          ?seq insdc:sequence_length ?seq_length
        }
      }
    SPARQL

    start_pos = [results.first[:start].to_i, results.first[:end].to_i].min
    end_pos = [results.first[:start].to_i, results.first[:end].to_i].max
    gene_length = (end_pos - start_pos).abs + 1
    display_start_pos = [1, start_pos - (gene_length*5)].max
    display_end_pos = [end_pos + (gene_length*5), results.first[:seq_length].to_i].min
    display_range = {:ref => results.first[:seq_label], :disp_start => display_start_pos, :disp_end => display_end_pos }
  end
end
