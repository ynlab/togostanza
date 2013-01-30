class ProteinCrossReferencesStanza < Stanza::Base
  property :title do |gene_id|
    "Cross-references : #{gene_id}"
  end

  property :references do |gene_id|
    references = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?category ?abbreviation ?ref ?url_temp
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> ;
                 up:reviewed true .

        ?protein rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:category ?category ;
                  up:abbreviation ?abbreviation ;
                  up:UrlTemplate ?url_temp .
      }
    SPARQL

    # merge でデータを付けた後、category、abbreviation でグループ化している
    # [{category: 'xxx', abbreviation: 'hoge', ref: 'aaa'}, {category: 'xxx', abbreviation: 'hoge', ref: 'bbb'}, {category: 'xxx', abbreviation: 'moge', ref: 'ccc'}, {category: 'yyy', abbreviation: 'fuga', ref: 'ddd'}]
    # => [[[{:category=>"xxx", :abbreviation=>"hoge", :ref=>"aaa"}, {:category=>"xxx", :abbreviation=>"hoge", :ref=>"bbb"}], [{:category=>"xxx", :abbreviation=>"moge", :ref=>"ccc"}]], [[{:category=>"yyy", :abbreviation=>"fuga", :ref=>"ddd"}]]]
    references.map {|hash|
      up_id  = hash[:protein].split('/').last
      ref_id = hash[:ref].split('/').last

      hash.merge(
        ref_id: ref_id,
        url:    hash[:url_temp].gsub(/%s|%u/, "%s" => ref_id, "%u" => up_id)
      )
    }.reverse.group_by {|hash| hash[:category] }.map {|hash|
      hash.last.group_by {|h| h[:abbreviation] }.values
    }
  end
end
