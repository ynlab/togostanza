class OrganismCultureCollectionsStanza < TogoStanza::Stanza::Base
  property :strain_list do |tax_id|
    results = query("http://togogenome.org/sparql", <<-SPARQL.strip_heredoc)
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT ?strain_id ?strain_number (?strain_name AS ?organism_name)
        ?isolation ((sql:GROUP_DIGEST(?env, '||', 1000, 1)) AS ?env_links)
        ?type_strain_label ?application
        ((sql:GROUP_DIGEST(?other_link, ', ', 1000, 1)) AS ?other_collections)
      FROM <http://togogenome.org/graph/taxonomy>
      FROM <http://togogenome.org/graph/brc>
      FROM <http://togogenome.org/graph/meo>
      WHERE
      {
        { SELECT DISTINCT ?strain_id
          {
            VALUES ?related_type  { mccv:MCCV_000056 mccv:MCCV_000022 mccv:MCCV_000057 }
            ?strain_id ?related_type  taxid:#{tax_id} .
          }
        }
        OPTIONAL { ?strain_id mccv:MCCV_000010 ?strain_number . }
        OPTIONAL { ?strain_id mccv:MCCV_000012 ?strain_name . }
        OPTIONAL { ?strain_id mccv:MCCV_000030 ?isolation . }
        OPTIONAL
        {
          ?strain_id mccv:MCCV_000059|mccv:MCCV_000060 ?meo_id .
          ?meo_id rdfs:label ?meo_label .
          BIND (CONCAT(REPLACE(STR(?meo_id),"http://purl.jp/bio/11/meo/",""), ?meo_label) AS ?env )
        }
        OPTIONAL { ?strain_id mccv:MCCV_000017 ?type_strain . BIND (IF(?type_strain = 1, "Yes","No") AS ?type_strain_label)}
        OPTIONAL { ?strain_id mccv:MCCV_000033 ?application . }
        OPTIONAL { ?strain_id mccv:MCCV_000024/mccv:MCCV_000026 ?other_link . }
      } GROUP BY ?strain_id ?strain_number ?strain_name ?type_strain_label ?isolation ?application
    SPARQL

    results.map {|hash|
      unless hash[:env_links] == "" then
        env_link_array = hash[:env_links].split("||")
        hash[:env_link_array] = env_link_array.map {|env_text|
          meo_info = { :meo_id => env_text.slice!(0, 11), :meo_label => env_text }
        }
        hash[:env_link_array].last[:is_last_data] = true
      end
    }
    results
  end
end
