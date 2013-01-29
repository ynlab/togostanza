class ProteinCrossReferencesStanza < Stanza::Base
  property :title do |gene_id|
    "Cross-references : #{gene_id}"
  end

  property :references do |gene_id|
    uniprot_url = query(:togogenome, <<-SPARQL).first[:up]
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX insdc: <http://rdf.insdc.org/>

      SELECT ?up
      WHERE {
        ?s insdc:feature_locus_tag "#{gene_id}" .
        ?s rdfs:seeAlso ?np .
        ?np rdf:type insdc:Protein .
        ?np rdfs:seeAlso ?up .
      }
    SPARQL

    references = query(:uniprot, <<-SPARQL)
      PREFIX up: <http://purl.uniprot.org/core/>

      SELECT DISTINCT ?protein ?category ?abbreviation ?ref ?url_temp
      WHERE {
        ?protein rdfs:seeAlso <#{uniprot_url}> .
        ?protein up:reviewed true .

        ?protein rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:category ?category .
        ?database up:abbreviation ?abbreviation .
        ?database up:UrlTemplate ?url_temp .
      }
    SPARQL

    # "http://purl.uniprot.org/<database>/<id>"
    database_url_pattern = /http:\/\/purl.uniprot.org\/(?<database>[\w|-]+)\/(?<id>[\w|\.|-|:]+)/

    # merge でデータを付けた後、category、abbreviation でグループ化している
    # [{category: 'xxx', abbreviation: 'hoge', ref: 'aaa'}, {category: 'xxx', abbreviation: 'hoge', ref: 'bbb'}, {category: 'xxx', abbreviation: 'moge', ref: 'ccc'}, {category: 'yyy', abbreviation: 'fuga', ref: 'ddd'}]
    # => [[[{:category=>"xxx", :abbreviation=>"hoge", :ref=>"aaa"}, {:category=>"xxx", :abbreviation=>"hoge", :ref=>"bbb"}], [{:category=>"xxx", :abbreviation=>"moge", :ref=>"ccc"}]], [[{:category=>"yyy", :abbreviation=>"fuga", :ref=>"ddd"}]]]
    references.map {|hash|
      up_id  = hash[:protein].match(database_url_pattern)[:id]
      ref_id = hash[:ref].match(database_url_pattern)[:id]

      hash.merge(
        ref_id: ref_id,
        link: hash[:url_temp].gsub(/%s|%u/, "%s" => ref_id, "%u" => up_id)
      )
    }.reverse.group_by {|hash| hash[:category] }.map {|hash|
      hash.last.group_by{|h| h[:abbreviation]}.map(&:last)
    }
  end
end
