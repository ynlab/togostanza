class PfamPlotStanza < Stanza::Base

  property (:selected_pfam_id) do |pfam_id|
    "#{pfam_id}"
  end

  property (:selected_pfam_name) do |pfam_id|
    pfam_name =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/cyano",<<-SPARQL.strip_heredoc)
      PREFIX pfam: <http://purl.uniprot.org/pfam/>

      SELECT ?label 
      WHERE
      {
        pfam:#{pfam_id} rdfs:comment ?label .
      } 
      SPARQL
    pfam_name.first[:label]
  end

  resource :plot_data do |pfam_id|
    sequence_list = Array::new
    habitat_list = Array::new
    phenotype_list = Array::new
    pfam_list = Array::new
    tax_label_list = Array::new

    sequence_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/togogenome",<<-SPARQL.strip_heredoc)
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX insdc: <http://rdf.insdc.org/>

      SELECT ?tax ?size ?num_gene ?num_trna ?num_rrna
      WHERE
      {
        {
          SELECT ?tax (COUNT(?gene) AS ?num_gene) (COUNT(?trna) AS ?num_trna) (COUNT(?rrna) AS ?num_rrna)
          WHERE
          {
            ?seq rdf:type ?obo_type ;
              rdfs:seeAlso ?tax
              FILTER (?obo_type = obo:SO_0000340 || ?obo_type = obo:SO_0000155) .
            ?tax rdf:type insdc:Taxonomy .
            { ?gene obo:so_part_of ?seq ; rdf:type obo:SO_0000704 . }
            UNION
            { ?trna obo:so_part_of ?seq ; rdf:type obo:SO_0000253 . }
            UNION
            { ?rrna obo:so_part_of ?seq ; rdf:type obo:SO_0000252 . }
          }
          GROUP BY ?tax
        }
        {
          SELECT ?tax (SUM(?len) AS ?size)
          WHERE
          {
            ?seq rdf:type ?obo_type ;
              insdc:sequence_length ?len ;
              rdfs:seeAlso ?tax
              FILTER (?obo_type = obo:SO_0000340 || ?obo_type = obo:SO_0000155) .
            ?tax rdf:type insdc:Taxonomy .
          }
          GROUP BY ?tax
        }
      }
    SPARQL
  ##temp
  #json_data = open('http://biointegra.jp/OpenID/data/genome_cyano.json').read
  #sequence_list0 = JSON.parser.new(json_data).parse()
  #sequence_list0.each { |i|
  #  sequence_list.push(i.symbolize_keys)
  #} 
  #p sequence_list

# SPARQL statement for filtering by tax_id
    tax_filter = "FILTER (?tax IN ("
    sequence_list.each_with_index { |entity, idx|
      s = entity[:tax]
      tax_filter << "tax:" << s.slice( s.rindex("/")+1 ,s.length )
      if idx < sequence_list.size - 1
        tax_filter << ", "
      end
    }
    tax_filter << "))"

    query2 = Thread.new do
      pfam_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/cyano",<<-SPARQL.strip_heredoc)
      #pfam_list =  query("http://beta.sparql.uniprot.org",<<-SPARQL.strip_heredoc)
        PREFIX up: <http://purl.uniprot.org/core/>
        PREFIX tax: <http://purl.uniprot.org/taxonomy/>
        PREFIX pfam: <http://purl.uniprot.org/pfam/>

        SELECT ?tax (SUM(?hits) as ?num_pfam) (count(distinct(?prot_id)) as ?num_pfam_protein) 
        WHERE 
        {
          ?prot_id up:organism ?tax #{tax_filter} .
          ?prot_id rdfs:seeAlso pfam:#{pfam_id} .
          ?id rdf:subject ?prot_id .
          ?id rdf:object pfam:#{pfam_id} .
          ?id up:hits ?hits .
        } GROUP BY ?tax
      SPARQL
    end
    
    query3 = Thread.new do
      habitat_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/gold2",<<-SPARQL.strip_heredoc)
        PREFIX meo: <http://purl.jp/bio/11/meo/>
        PREFIX mccv: <http://purl.jp/bio/01/mccv#>
        PREFIX tax: <http://identifiers.org/taxonomy/>
        
        SELECT ?tax (GROUP_CONCAT(distinct(?label2); SEPARATOR=",") as ?habitat)
        WHERE 
        {
          ?gold meo:environmentalDescribed ?envi .
          ?gold mccv:MCCV_000020 ?tax #{tax_filter} .
          ?envi rdf:type ?meo .
          ?meo rdfs:subClassOf* ?meo2 .
          ?meo2 rdfs:subClassOf owl:Thing.
          ?meo2 rdfs:label ?label2 .
        }
        GROUP BY ?tax ORDER BY ?tax ?meo2
      SPARQL
    end

    query4 = Thread.new do
      phenotype_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/gold2",<<-SPARQL.strip_heredoc)
        PREFIX mpo:<http://purl.jp/bio/01/mpo#>
        PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
        PREFIX tax: <http://identifiers.org/taxonomy/>

        SELECT distinct ?tax ?cell_shape_label ?temp_range_label ?opt_temp ?min_temp ?max_temp ?oxy_req_label ?opt_ph ?min_ph ?max_ph
        WHERE
        {
          ?tax ?p ?o #{tax_filter} .
          OPTIONAL 
          {
            ?tax mpo:MPO_10001 ?cell_shape.
            ?cell_shape skos:prefLabel ?cell_shape_label .
          }
          OPTIONAL 
          {
            ?tax mpo:MPO_10003 ?temp_range.
            ?temp_range skos:prefLabel ?temp_range_label .
          }
          OPTIONAL { ?tax mpo:MPO_10009 ?opt_temp . }
          OPTIONAL 
          { 
            ?tax mpo:MPO_10010 ?min_temp .
            ?tax mpo:MPO_10011 ?max_temp .
          }
          OPTIONAL 
          {
            ?tax mpo:MPO_10002 ?oxy_req .
            ?oxy_req skos:prefLabel ?oxy_req_label .
          }
          OPTIONAL { ?tax mpo:MPO_10005 ?opt_ph . }
          OPTIONAL 
          {
            ?tax mpo:MPO_10006 ?min_ph .
            ?tax mpo:MPO_10007 ?max_ph .
          }
        }
      SPARQL
    end

    query5 = Thread.new do
      tax_label_list =  query("http://lod.dbcls.jp/openrdf-sesame5l/repositories/ncbitaxon",<<-SPARQL.strip_heredoc)
        PREFIX tax: <http://purl.obolibrary.org/obo/NCBITaxon_>

        SELECT ?tax ?label
        WHERE
        {
          ?tax rdfs:label ?label #{tax_filter} .
        }
      SPARQL
    end

    query2.join
    query3.join
    query4.join
    query5.join

#merge sequence data with habitat data
    habitat_hash = Hash::new
    habitat_list.each { |i|
      habitat_hash[i[:tax]] = i
    }

    sequence_list.each { |i|
        if habitat_hash[i[:tax]] && habitat_hash[i[:tax]][:habitat]
          i[:habitat] = habitat_hash[i[:tax]][:habitat]
        end
    }

#merge taxonomy sequence data with phenotype data
    phenotype_hash = Hash::new
    phenotype_list.each { |i|
      phenotype_hash[i[:tax]] = i
    }

    items = [:cell_shape_label, :temp_range_label, :oxy_req_label, :opt_temp, :min_temp, :max_temp, :opt_ph, :min_ph, :max_ph ]
    sequence_list.each { |i|
      items.each { |item|
        if phenotype_hash[i[:tax]] && phenotype_hash[i[:tax]][item]
          i[item] = phenotype_hash[i[:tax]][item]
        end
      }
    }

#merge sequence data with pfam data
    pfam_hash = Hash::new
    pfam_list.each { |i|
      tax_id = i[:tax].gsub("http://purl.uniprot.org/taxonomy/", "http://identifiers.org/taxonomy/")
      pfam_hash[tax_id] = i
    }

    items = [:num_pfam, :num_pfam_protein] 
    sequence_list.each { |i|
      items.each { |item|
        if pfam_hash[i[:tax]] && pfam_hash[i[:tax]][item]
          i[item] = pfam_hash[i[:tax]][item]
        end
      }
    }

#merge sequence data with taxonomy label
    tax_label_hash = Hash::new
    tax_label_list.each { |i|
      tax_id = i[:tax].gsub("http://purl.obolibrary.org/obo/NCBITaxon_", "http://identifiers.org/taxonomy/")
      tax_label_hash[tax_id] = i
    }

    sequence_list.each { |i|
        if tax_label_hash[i[:tax]] && tax_label_hash[i[:tax]][:label]
          i[:label] = tax_label_hash[i[:tax]][:label]
        end
    }

  end
end
