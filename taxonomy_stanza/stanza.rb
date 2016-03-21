class TaxonomyStanza < TogoStanza::Stanza::Base
  property :taxonomy do |taxonomy_id|
    taxonomy_id = 1117 if taxonomy_id.blank?

    query("http://staging-genome.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>
      SELECT
        ?root
        ?step
        (REPLACE(STR(?tax), "http://identifiers.org/taxonomy/", "") AS ?tax_id)
        (?tax as ?tax_link)
        ?tax_label 
        (REPLACE(STR(?rank), "http://ddbj.nig.ac.jp/ontologies/taxonomy/", "") AS ?rank)
        #* 
      WHERE
      {
        ?search_tax rdfs:label ?root FILTER (?search_tax = taxid:1117 ) .
        #?tax rdfs:subClassOf+ ?search_tax.
        ?tax rdfs:subClassOf ?search_tax OPTION (transitive, t_direction 1, t_min(0), t_step("step_no") as ?step) .
        ?tax rdfs:label ?tax_label .
        OPTIONAL { ?tax taxo:rank ?rank . }
        #FILTER(?tax != taxid:1)
      } 
    SPARQL
  end
      
  property :taxonomy_root do |taxonomy_id|
    taxonomy_id = 1117 if taxonomy_id.blank?

    query("http://staging-genome.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy/>
      PREFIX taxid: <http://identifiers.org/taxonomy/>

      SELECT
       (REPLACE(STR(?tax), "http://identifiers.org/taxonomy/", "") AS ?tax_no)
       (?tax AS ?tax_link)
       ?tax_label
       (REPLACE(STR(?rank), "http://ddbj.nig.ac.jp/ontologies/taxonomy#", "") AS ?rank)
#      FROM <http://ddbj.nig.ac.jp/ontologies/taxonomy/>
      WHERE
      {
        #?search_tax rdfs:label ?o FILTER (?search_tax = taxid:#{taxonomy_id} ) .
        ?search_tax rdfs:label ?o FILTER (?search_tax = taxid:1148 ) .
        ?search_tax rdfs:subClassOf ?tax OPTION (transitive, t_direction 1, t_min(0), t_step("step_no") as ?step) .
        ?tax rdfs:label ?tax_label .
        OPTIONAL { ?tax taxo:rank ?rank . }
        #OPTIONAL { ?tax ?x ?y. }
        FILTER(?tax != taxid:1)
      } ORDER BY DESC(?step)
    SPARQL
  end 

end
