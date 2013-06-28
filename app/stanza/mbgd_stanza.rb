class MbgdStanza < Stanza::Base

  # tax_id = "1111708"
  # gene_id = "slr1311"

  property :title do |tax_id, gene_id|
    "Orthologs of #{tax_id}:#{gene_id}"
  end

  property :orthologs do |tax_id, gene_id|
    protein_attributes = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?upid
      WHERE {
        ?upid up:organism  taxonomy:#{tax_id} ;
                 rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
      }
    SPARQL
	$stderr.puts ">>>>>hoge1"
    $stderr.puts protein_attributes.inspect
    $stderr.puts protein_attributes.class
    $stderr.puts protein_attributes.first
    $stderr.puts protein_attributes.first.class
    $stderr.puts protein_attributes.first.keys.inspect
    $stderr.puts protein_attributes.first.values.inspect
	$stderr.puts ">>>>>hoge1"

    # uniprot_uri = "<http://purl.uniprot.org/uniprot/P16033>"
	uniprot_uri = protein_attributes.first[:upid]
	$stderr.puts ">>>>>hoge2"
    $stderr.puts uniprot_uri
	$stderr.puts ">>>>>hoge2"

    ortholog_uris = query("http://mbgd.genome.ad.jp:8047/sparql", <<-SPARQL.strip_heredoc)
       PREFIX mbgd: <http://mbgd.genome.ad.jp:8036/rdf/rdf-schema#>
       
       SELECT ?upid
       WHERE {
         ?gene mbgd:uniprotId <#{uniprot_uri}> .
         ?domain mbgd:domainOf ?gene .
         ?cluster mbgd:member ?domain .
       
         ?cluster mbgd:member ?domains .
         ?domains mbgd:domainOf ?genes .
         ?genes mbgd:uniprotId ?upid .
       }
    SPARQL
  end

end
