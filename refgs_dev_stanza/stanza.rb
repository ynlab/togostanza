class RefgsDevStanza < TogoStanza::Stanza::Base
  property :features do |sra|
    uri = "http://identifiers.org/insdc.sra/" + "#{sra}" 
    features = query('http://genome.microbedb.jp/sparql', <<-SPARQL.strip_heredoc)
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX asm: <http://www.ncbi.nlm.nih.gov/assembly/>
      PREFIX refgs: <http://tga.nig.ac.jp/refgs/resource/>

      select DISTINCT ?srx_id ?biosample_id ?srs_id ?bioproject_id ?asm_id ?organism_name ?infraspecific_name ?tax_id ?refseq_id 
      from <http://genome.microbedb.jp/dev/refgs>
      from <http://genome.microbedb.jp/graph/assembly>
      where
      {

        ?sub ?pre ?obj.

        # ?experiment
        ?sub rdfs:label ?srx_id.

        # ?biosample
        ?sub insdc:dblink ?bs.
        ?bs a <http://ddbj.nig.ac.jp/ontologies/nucleotide/BioSample>.
        ?bs rdfs:label ?biosample_id.

        # ?bioproject_id
        ?sub insdc:dblink ?bp.
        ?bp a <http://ddbj.nig.ac.jp/ontologies/nucleotide/BioProject>.
        ?bp rdfs:label ?bioproject_id.

        # ?bioproject_id
        ?sub insdc:dblink ?srs.
        ?srs a <http://ddbj.nig.ac.jp/ontologies/nucleotide/SRA-Sample>.
        ?srs rdfs:label ?srs_id.

        # ?run
        ?sub insdc:dblink ?srr.
        ?srr a <http://ddbj.nig.ac.jp/ontologies/nucleotide/SRA-Run>.
        ?srr rdfs:label ?srr_id.

        # ?refseq_id
        ?rc  refgs:query   ?sub.
        ?rc  refgs:subject ?refseq_uri.
        ?rc  refgs:score   ?score.
        ?seq asm:refseq ?refseq_uri.
        ?seq asm:refseq_accession ?refseq_id.
        ?asm asm:sequence ?seq.
        ?asm asm:organism_name ?organism_name.
        ?asm asm:infraspecific_name ?infraspecific_name.
        ?asm asm:tax_id ?tax_id.
        ?asm asm:assembly_id ?asm_id.

       FILTER(?sub = <#{uri}> || ?obj = <#{uri}>)

      }
      ORDER BY ?srx_id ?asm_id
      limit 1000

    SPARQL
  end
end

