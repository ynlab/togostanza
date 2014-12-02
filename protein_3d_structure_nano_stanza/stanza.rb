class Protein3dStructureNanoStanza < TogoStanza::Stanza::Base
  property :pdb do |tax_id, gene_id|
    result = query("http://togostanza.org/sparql", <<-SPARQL.strip_heredoc).first
      PREFIX core: <http://purl.uniprot.org/core/>

      SELECT ?up ?attr ?url
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?up .
        ?up a core:Protein .
        ?attr rdf:subject ?up .
        ?attr a core:Structure_Mapping_Statement .
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
