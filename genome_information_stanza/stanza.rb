class GenomeInformationStanza < TogoStanza::Stanza::Base
  property :genome_info_list do |tax_id|
    results = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/sequence#>
      PREFIX idtax: <http://identifiers.org/taxonomy/>
      PREFIX togo: <http://togogenome.org/stats/>
      
      SELECT ?bioproject ?bioproject_id ?refseq_version ?refseq_link ?desc ?replicon_type ?sequence_length
       ?gene_cnt ?trna_cnt ?rrna_cnt ?other_cnt
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
      FROM <http://togogenome.org/graph/stats/>
      WHERE
      {
        ?seq rdfs:seeAlso idtax:#{tax_id} ;
          rdfs:label ?desc ;
          rdfs:seeAlso ?bioproject ;
          insdc:sequence_version ?refseq_version ;
          insdc:sequence_length ?sequence_length ;
          rdfs:seeAlso ?refseq_link ;
          a ?so FILTER (?so =  obo:SO_0000340 || ?so = obo:SO_0000155) .
        ?so rdfs:label ?replicon_type .
        ?bioproject a <http://identifiers.org/bioproject/> ;
          rdfs:label ?bioproject_id .
        ?refseq_link a <http://identifiers.org/refseq/> ;
          togo:gene ?gene_cnt ;
          togo:rrna ?rrna_cnt ;
          togo:trna ?trna_cnt ;
          togo:other ?other_cnt .
      }
    SPARQL

    results.reverse.group_by {|hash| hash[:bioproject_id] }.map {|hash|
      hash.last.sort_by {|hash2|
        hash2[:replicon_type]
      }
    }
  end
end
