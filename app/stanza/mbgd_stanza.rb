class MbgdStanza < Stanza::Base
  # tax_id = "1111708"
  # gene_id = "slr1311"
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

    # uniprot_uri = "<http://purl.uniprot.org/uniprot/P16033>"
    uniprot_uri = protein_attributes.first[:upid]

    query("http://mbgd.genome.ad.jp:8047/sparql", <<-SPARQL.strip_heredoc)
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
