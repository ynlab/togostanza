class Protein3dStructureNanoStanza < TogoStanza::Stanza::Base
  property :pdb do |refseq_id, gene_id|
    result = query("http://dev.togogenome.org/sparql-test", <<-SPARQL.strip_heredoc).first
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT ?protein ?attr ?url
      FROM <http://togogenome.org/graph/uniprot>
      FROM <http://togogenome.org/graph/tgup>
      WHERE {
        <http://togogenome.org/gene/#{refseq_id}:#{gene_id}> rdfs:seeAlso ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a up:Protein .
        ?attr rdf:subject ?protein .
        ?attr a up:Structure_Mapping_Statement .
        ?attr rdf:object ?url .
      }
    SPARQL

    if result
      result.merge(img_url: "http://www.rcsb.org/pdb/images/#{result[:url][-4, 4].downcase!}_bio_r_500.jpg")
    else
      nil
    end
  end
end
