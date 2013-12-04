class OrganismMediumInformationStanza < TogoStanza::Stanza::Base
  property :medium_information do |tax_id|
    medium_list = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX gmo: <http://purl.jp/bio/11/gmo#>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT DISTINCT ?medium_id ?medium_type_label ?medium_name
      FROM <http://togogenome.org/graph/brc/>
      FROM <http://togogenome.org/graph/gmo/>
      WHERE
      {
        VALUES ?classification { gmo:GMO_000015 gmo:GMO_000016 gmo:GMO_000008 gmo:GMO_000009 }
        { SELECT DISTINCT ?medium
          {
            ?strain_id mccv:MCCV_000056 taxid:#{tax_id} .
            ?strain_id mccv:MCCV_000018 ?medium .
          }
        }
        ?medium gmo:GMO_000101 ?medium_id .
        ?medium gmo:GMO_000111 ?medium_type .
        ?medium_type rdfs:label ?medium_type_label FILTER (lang(?medium_type_label) = "en") .
        OPTIONAL { ?medium gmo:GMO_000102 ?medium_name } .
      }
    SPARQL

    ingredient_list = query("http://ep.dbcls.jp/sparql7upd2", <<-SPARQL.strip_heredoc)
#      DEFINE sql:select-option "order"
# TODO: Uncomment the above line when endpoint data is update. 
      PREFIX mccv: <http://purl.jp/bio/01/mccv#>
      PREFIX gmo: <http://purl.jp/bio/11/gmo#>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT ?medium_id ?classification (STR(?class_label) AS ?class_label)
        ((sql:GROUP_DIGEST(?ingredient_label , ',  ', 1000, 1)) AS ?ingredients)
      FROM <http://togogenome.org/graph/brc/>
      FROM <http://togogenome.org/graph/gmo/>
      WHERE
      {
        VALUES ?classification { gmo:GMO_000015 gmo:GMO_000016 gmo:GMO_000008 gmo:GMO_000009 }
        { SELECT DISTINCT ?medium
          {
            ?strain_id mccv:MCCV_000056 taxid:#{tax_id} .
            ?strain_id mccv:MCCV_000018 ?medium .
          }
        }
        ?medium gmo:GMO_000101 ?medium_id .
        ?medium gmo:GMO_000104 ?ingredient .
        ?ingredient rdfs:subClassOf* ?classification .
        ?ingredient rdfs:label ?ingredient_label FILTER (lang(?ingredient_label) = "en") .
        ?classification rdfs:label ?class_label .
      } GROUP BY ?medium_id ?classification ?class_label
    SPARQL

    ingredients = ingredient_list.group_by {|hash| hash[:medium_id] }
    ingredients_classes = ["GMO_000015", "GMO_000016", "GMO_000008", "GMO_000009"]
    result = medium_list.map {|hash|
      row = []
      row.push({:row_key => "Medium ID", :row_value => hash[:medium_id]})
      row.push({:row_key => "Medium name", :row_value => hash[:medium_name]})
      row.push({:row_key => "Medium type", :row_value => hash[:medium_type_label]})
      ingredients_classes.each{ |classes|
        classification = ingredients[hash[:medium_id]].find {|item| item[:classification].split("#").last == classes }
        row.push({:row_key => classification[:class_label], :row_value => classification[:ingredients]})
      }
      row
    }
    result
  end
end
