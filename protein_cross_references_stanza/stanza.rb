class ProteinCrossReferencesStanza < TogoStanza::Stanza::Base
  property :references do |tax_id, gene_id|
    references = query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT ?protein ?category ?abbr ?ref ?url_template
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE {

        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a <http://purl.uniprot.org/core/Protein> ;
          rdfs:seeAlso    ?ref .
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
        url:    url(hash[:url_template], hash[:abbr], ref_id, up_id)
      )
    }.reverse.group_by {|hash| hash[:category] }.map {|hash|
      hash.last.group_by {|h| h[:abbr] }.values
    }
  end

  private

  # UniProt の url_template データが誤っていると考えられる
  # UniProt のデータが更新された後は、要確認(逆にバグとなってしまう可能性があるため)
  def url(url_template, abbr, ref_id, up_id)
    case abbr
    when 'eggNOG'
      url_template.gsub(/%s|%u/, "%s" => up_id, "%u" => up_id)
    when 'ProtClustDB'
      url_template.gsub(/%s|%u/, "%s" => ref_id, "%u" => ref_id)
    else
      url_template.gsub(/%s|%u/, "%s" => ref_id, "%u" => up_id)
    end
  end
end
