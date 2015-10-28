class GenomeInformationStanza < TogoStanza::Stanza::Base
  property :genome_info_list do |tax_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX idtax: <http://identifiers.org/taxonomy/>
      PREFIX togo: <http://togogenome.org/stats/>

      SELECT  ?bioproject  ?bioproject_id ?refseq_version ?refseq_link  ?desc ?replicon_type ?sequence_length
       ?gene_cnt ?rrna_cnt ?trna_cnt ?other_cnt
      FROM <http://togogenome.org/graph/refseq>
      FROM <http://togogenome.org/graph/so>
      FROM <http://togogenome.org/graph/stats>
      WHERE
      {
        idtax:#{tax_id} rdfs:seeAlso ?bioproject .
        ?bioproject a insdc:BioProject ;
          rdfs:label ?bioproject_id .
        ?refseq_link insdc:dblink ?bioproject ;
          a insdc:Entry ;
          insdc:sequence_version ?refseq_version ;
          insdc:definition ?desc ;
          insdc:sequence ?seq.
        ?seq rdfs:subClassOf/rdfs:label ?replicon_type ;
          insdc:sequence_length ?sequence_length .
        ?refseq_link  togo:gene ?gene_cnt ;
          togo:rrna ?rrna_cnt ;
          togo:trna ?trna_cnt ;
          togo:other ?other_cnt .
      } ORDER BY ?bioproject_id ?refseq_version
    SPARQL

    results.reverse.group_by {|hash| hash[:bioproject_id] }.map {|hash|
      hash.last.sort_by {|hash2|
        hash2[:replicon_type]
      }
    }
  end
end
