class EnvironmentGoldSamplesStanza < Stanza::Base
  property :gold_sample_list do |meo_id|
    results = query(:togogenome, <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX meo: <http://purl.jp/bio/11/meo/>
      PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy#>
      
      SELECT 
       ?gold REPLACE(STR(?gold) ,"http://www.genomesonline.org/cgi-bin/GOLD/GOLDCards.cgi\\\\?goldstamp=" ,"" ) AS ?gold_no
       ?tax_id ?organism_name
       (sql:GROUP_DIGEST(?env, '||', 1000, 1)) AS ?env_links
      FROM <http://togogenome.org/graph/gold/>
      FROM <http://togogenome.org/graph/meo/>
      FROM <http://togogenome.org/graph/taxonomy/>
      {
        VALUES ?meo_mapping { meo:MEO_0000437 meo:MEO_0000440 }
        ?meo_id rdfs:subClassOf* meo:#{meo_id} .
        ?gold ?meo_mapping ?meo_id .
        ?meo_id rdfs:label ?meo_label .
        BIND (CONCAT(REPLACE(STR(?meo_id),"http://purl.jp/bio/11/meo/",""), ?meo_label) AS ?env ) 
        OPTIONAL 
        {
          ?gold mccv:MCCV_000020 ?tax_id . 
          ?tax_id taxo:scientificName ?organism_name
        }
      } GROUP BY ?gold ?tax_id ?organism_name
    SPARQL

    results.map {|hash|
      unless hash[:env_links] == "" then
        env_link_array = hash[:env_links].split("||")
        hash[:env_link_array] = env_link_array.map {|env_text|
          meo_info = { :meo_id => env_text.slice!(0, 11), :meo_label => env_text }
        }
        hash[:env_link_array].last[:is_last_data] = true
        unless hash[:tax_id].nil? then
          hash[:tax_id] = hash[:tax_id].split('/').last
        end
      end
    }
    results
  end
end
