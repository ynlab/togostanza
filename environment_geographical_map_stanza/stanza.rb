class EnvironmentGeographicalMapStanza < TogoStanza::Stanza::Base
  property :select_meo_id do |meo_id|
    meo_id
  end

  resource :place_list do |meo_id|
    gazetter = []
    results = query(:togogenome, <<-SPARQL.strip_heredoc)
      PREFIX meo: <http://purl.jp/bio/11/meo/>
      PREFIX msv: <http://purl.jp/bio/11/msv/>

      SELECT
        ?gold REPLACE(STR(?gold),"http://www.genomesonline.org/cgi-bin/GOLD/GOLDCards.cgi\\\\?goldstamp=","") AS ?gold_id
        ?gaz AS ?gaz_id ?place_name ?latitude ?longitude
      FROM <http://togogenome.org/graph/gold/>
      FROM <http://togogenome.org/graph/meo/>
      FROM <http://togogenome.org/graph/gazetteer/>
      {
        ?meo_id rdfs:subClassOf* meo:#{meo_id} .
        ?gold meo:MEO_0000437 ?meo_id .
        ?gold meo:MEO_0000438 ?gaz .
        ?gaz rdfs:label ?place_name .
        ?gaz msv:latitude ?latitude .
        ?gaz msv:longitude ?longitude .
      }
    SPARQL

    if results == nil || results.size == 0 then
      next
    end

    results.each do |entity|
      gaz = Hash.new
      gaz[:label] = entity[:place_name].gsub(' ','').gsub(/'/, "_").gsub(/-/, "_")
      gaz[:gaz_id] = entity[:gaz_id]
      gaz[:place_name] = entity[:place_name]
      gaz[:latitude] = entity[:latitude]
      gaz[:longitude] = entity[:longitude]
      gaz[:goldlist] = []
      gazetter.push(gaz)
    end
    gazetter = gazetter.uniq!
    gazetter.each do |entity|
      results.each do |result_entity|
        if (entity[:gaz_id] == result_entity[:gaz_id]) then
          golddata = Hash.new
          golddata[:gold] = result_entity[:gold]
          golddata[:gold_id] = result_entity[:gold_id]
          entity[:goldlist].push(golddata)
        end
      end
    end
    gazetter
  end
end
