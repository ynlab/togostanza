class GenomeInformationStanza < Stanza::Base
  property :genome_info_list do |tax_id|
    results = query(:togogenome, <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://insdc.org/owl/>
      PREFIX idorg: <http://rdf.identifiers.org/database/>
      PREFIX idtax: <http://identifiers.org/taxonomy/>
      
      SELECT  ?bioproject ?bioproject_id ?refseq_version ?desc ?replicon_type ?sequence_length
       count(?gene_locus_tag) as ?gene_cnt
       count(?trna_locus_tag) as ?trna_cnt
       count(?rrna_locus_tag) as ?rrna_cnt
       count(?other_locus_tag) as ?other_cnt
      FROM <http://togogenome.org/graph/refseq/>
      FROM <http://togogenome.org/graph/so/>
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
        ?bioproject a idorg:BioProject ;
          rdfs:label ?bioproject_id .
        ?refseq_link a idorg:RefSeq .
        {
          ?gene obo:so_part_of ?seq ;
            a obo:SO_0000704 ;
            insdc:feature_locus_tag ?gene_locus_tag .
        }
        UNION
        {
          ?trna obo:so_part_of ?seq ;
            a obo:SO_0000253 ;
          insdc:feature_locus_tag ?trna_locus_tag .
        }
        UNION
        {
          ?rrna obo:so_part_of ?seq ;
            a obo:SO_0000252 ;
            insdc:feature_locus_tag ?rrna_locus_tag .
        }
        UNION
        {
          ?other obo:so_part_of ?seq ;
            a ?obotype ;
            insdc:feature_locus_tag ?other_locus_tag
              FILTER (?obotype != obo:SO_0000704 && ?obotype != obo:SO_0000253 && ?obotype != obo:SO_0000252) .
        }
      }
    SPARQL

    results.reverse.group_by {|hash| hash[:bioproject_id] }.map {|hash|
      hash.last.sort_by {|hash2|
        hash2[:replicon_type]
      }
    }
  end
end
