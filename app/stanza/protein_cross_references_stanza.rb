class ProteinCrossReferencesStanza < Stanza::Base
  property :title do |gene_id|
    "Cross-references : #{gene_id}"
  end

  property :references do |gene_id|
    references = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?category ?abbr ?ref ?url_template
      WHERE {
        ?protein  rdfs:seeAlso    <#{uniprot_url_from_togogenome(gene_id)}> ;
                  up:reviewed     true .

        ?protein  rdfs:seeAlso    ?ref .
        ?ref      up:database     ?database .
        ?database up:category     ?category ;
                  up:abbreviation ?abbr ;
                  up:UrlTemplate  ?url_template .
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
