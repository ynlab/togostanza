class ProteinCrossReferencesStanza < Stanza::Base
  property :references do |tax_id, gene_id|
    references = query(:uniprot, <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT ?protein ?category ?abbr ?ref ?url_template
      WHERE {
        GRAPH <http://togogenome.org/graph/> {
          <http://togogenome.org/uniprot/> dct:isVersionOf ?g .
        }

        GRAPH ?g {
          ?protein up:organism  taxonomy:#{tax_id} ;
                   rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .

          ?protein  rdfs:seeAlso    ?ref .
          ?ref      up:database     ?database .
          ?database up:category     ?category ;
                    up:abbreviation ?abbr ;
                    up:UrlTemplate  ?url_template .
        }
      }
    SPARQL

    # merge でデータを付けた後、category、abbr でグループ化している
    # [{category: 'xxx', abbr: 'hoge', ref: 'aaa'}, {category: 'xxx', abbr: 'hoge', ref: 'bbb'}, {category: 'xxx', abbr: 'moge', ref: 'ccc'}, {category: 'yyy', abbr: 'fuga', ref: 'ddd'}]
    # => [[[{:category=>"xxx", :abbr=>"hoge", :ref=>"aaa"}, {:category=>"xxx", :abbr=>"hoge", :ref=>"bbb"}], [{:category=>"xxx", :abbr=>"moge", :ref=>"ccc"}]], [[{:category=>"yyy", :abbr=>"fuga", :ref=>"ddd"}]]]
    references.map {|hash|
      up_id  = hash[:protein].split('/').last
      ref_id = hash[:ref].split('/').last

      hash.merge(
        ref_id: ref_id,
        url:    hash[:url_template].gsub(/%s|%u/, "%s" => ref_id, "%u" => up_id)
      )
    }.reverse.group_by {|hash| hash[:category] }.map {|hash|
      hash.last.group_by {|h| h[:abbr] }.values
    }
  end
end
