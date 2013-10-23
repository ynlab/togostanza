class ProteinOrthologsStanza < TogoStanza::Stanza::Base
  property :orthologs do |tax_id, gene_id|
    protein_attributes = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?upid
      WHERE {
        ?upid up:organism taxonomy:#{tax_id} ;
          rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
      }
    SPARQL

    # uniprot_uri = "<http://purl.uniprot.org/uniprot/P16033>"
    uniprot_uri = protein_attributes.first[:upid]

    ortholog_uris = query("http://sparql.nibb.ac.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX mbgd: <http://mbgd.genome.ad.jp/owl/mbgd.owl#>
      PREFIX orth: <http://mbgd.genome.ad.jp/owl/ortholog.owl#>
      PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
      PREFIX uniprotCore: <http://purl.uniprot.org/core/>

      SELECT ?protein
      WHERE {
        ?group a orth:OrthologGroup ;
          orth:member/mbgd:gene/mbgd:uniprot <#{uniprot_uri}> ;
          orth:member/mbgd:gene/mbgd:uniprot ?protein .
      }
    SPARQL

    ortholog_uris.map {|hash|
      hash[:protein_label] = hash[:protein].gsub('http://purl.uniprot.org/uniprot/','')
    }
    ortholog_uris.last[:is_last_data] = true
    ortholog_uris
  end
end
