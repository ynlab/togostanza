class RefgsDev2Stanza < TogoStanza::Stanza::Base
  property :features do |sra|
    uri = "http://identifiers.org/insdc.sra/" + "#{sra}" 
    features = query('http://genome.microbedb.jp/sparql', <<-SPARQL.strip_heredoc)
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
      PREFIX refgs: <http://tga.nig.ac.jp/refgs/resource/>

      select DISTINCT ?srx_id ?refseq_uri ?refseq_id ?score
      from <http://genome.microbedb.jp/dev/refgs>
      from <http://genome.microbedb.jp/graph/assembly>
      where
      {

        ?sub ?pre ?obj.

        # ?experiment
        ?sub rdfs:label ?srx_id.

        # ?refseq_id
        ?rc  refgs:query   ?sub.
        ?rc  refgs:subject ?refseq_uri.
        ?rc  refgs:score   ?score.
        ?seq asm:refseq ?refseq_uri.        
        ?seq asm:refseq_accession ?refseq_id.

       FILTER(?sub = <#{uri}> || ?obj = <#{uri}>)

      } 
      limit 10000

    SPARQL
  end
end


