class PfamPlotStanza < Stanza::Base
  property :selected_pfam_id do |tax_id,gene_id|
    pfam_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT  REPLACE(STR(?ref), "http://purl.uniprot.org/pfam/","") AS ?pfam_id
      FROM <http://togogenome.org/uniprot/>
      WHERE
      {
        ?protein up:organism taxonomy:#{tax_id} ;
          rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:abbreviation ?abbr
        FILTER (?abbr ='Pfam').
      }
    SPARQL

    pfam_id = pfam_list.first[:pfam_id]
  end

  property :selected_tax_id do |tax_id|
    tax_id
  end

  property :selected_gene_id do |gene_id|
    gene_id
  end

  property :selected_pfam_name do |tax_id,gene_id|
    pfam_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT  REPLACE(STR(?ref), "http://purl.uniprot.org/pfam/","") AS ?pfam_id
      FROM <http://togogenome.org/uniprot/>
      WHERE
      {
        ?protein up:organism taxonomy:#{tax_id} ;
          rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:abbreviation ?abbr
        FILTER (?abbr ='Pfam').
      }
    SPARQL

    pfam_id = pfam_list.first[:pfam_id]

    pfam_name =  query('http://biointegra.jp/sparql3', <<-SPARQL.strip_heredoc)
      PREFIX pfam: <http://purl.uniprot.org/pfam/>

      SELECT ?label
      WHERE
      {
        pfam:#{pfam_id} rdfs:comment ?label .
      }
    SPARQL

    pfam_name.first[:label]
  end

  resource :plot_data do |tax_id,gene_id|
     habitat_list =[]
     summary_list = []
     genome_list = []
     pfam_list = []
     pfam_summary_list = []

    pfam_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>
      PREFIX dct:   <http://purl.org/dc/terms/>

      SELECT DISTINCT  REPLACE(STR(?ref), "http://purl.uniprot.org/pfam/","") AS ?pfam_id
      FROM <http://togogenome.org/uniprot/>
      WHERE
      {
        ?protein up:organism taxonomy:#{tax_id} ;
          rdfs:seeAlso <#{uniprot_url_from_togogenome(gene_id)}> .
        ?protein rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:abbreviation ?abbr
        FILTER (?abbr ='Pfam').
      }
    SPARQL

    pfam_id =  pfam_list.first[:pfam_id]

    query1 = Thread.new {
      habitat_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
        PREFIX owl: <http://www.w3.org/2002/07/owl#>
        PREFIX meo: <http://purl.jp/bio/11/meo/>
        PREFIX mccv: <http://purl.jp/bio/01/mccv#>

        SELECT  ?tax (sql:GROUP_DIGEST (?label, ', ', 1000, 1)) as ?habitat
        FROM <http://togogenome.org/gold/>
        FROM <http://togogenome.org/gold_meo0_5test/> #temporary
        FROM <http://togogenome.org/meov0_5test/> #temporary
        WHERE
        {
         ?gold mccv:MCCV_000020 ?tax FILTER regex(?tax, "^http://identifiers.org/") .
         ?gold meo:MEO_0000437 ?meo .
         ?meo a owl:Class ;
           rdfs:subClassOf* ?parent .
           ?parent rdfs:label ?label.
         ?parent meo:MEO_0000442 "1"
        } GROUP BY ?tax
      SPARQL
    }
 
    query2 = Thread.new {
      genome_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
        DEFINE sql:select-option "order"
        PREFIX owl: <http://www.w3.org/2002/07/owl#>
        PREFIX meo: <http://purl.jp/bio/11/meo/>
        PREFIX mccv: <http://purl.jp/bio/01/mccv#>
        PREFIX mpo:<http://purl.jp/bio/01/mpo#>
        PREFIX obo: <http://purl.obolibrary.org/obo/>
        PREFIX insdc: <http://insdc.org/owl/>
        PREFIX idorg:<http://rdf.identifiers.org/database/>
 
        SELECT
          ?tax ?bioProject ?organism_name ?genome_length
          (sql:GROUP_DIGEST (?cell_shape_label, ', ', 1000, 1)) AS ?cell_shape_label
          (sql:GROUP_DIGEST (?temp_range_label, ', ', 1000, 1)) AS ?temp_range_label
          (sql:GROUP_DIGEST (?oxy_req_label, ', ', 1000, 1)) AS ?oxy_req_label
          ?opt_temp ?min_temp ?max_temp ?opt_ph ?min_ph ?max_ph
        FROM <http://togogenome.org/refseq/>
        FROM <http://togogenome.org/mpo/> #TODO change to gold
        FROM <http://togogenome.org/ncbitaxon/>
        {
          {
            SELECT  ?tax ?bioProject SUM(?seq_len) AS ?genome_length IRI(REPLACE(str(?tax),"http://identifiers.org/taxonomy/","http://purl.obolibrary.org/obo/NCBITaxon_")) AS ?taxon
            FROM <http://togogenome.org/refseq/>
            WHERE
            {
              ?tax rdf:type idorg:Taxonomy .
              ?seq rdfs:seeAlso ?tax ;
              rdf:type ?obo_type FILTER(?obo_type IN (obo:SO_0000340, obo:SO_0000155 )).
              ?seq insdc:sequence_length ?seq_len ;
                rdfs:seeAlso ?bioProject.
              ?bioProject rdf:type idorg:BioProject .
            } GROUP BY ?tax  ?bioProject
          }
          OPTIONAL { ?tax mpo:MPO_10001/rdfs:label ?cell_shape_label  FILTER (lang(?cell_shape_label) = "en") .}
          OPTIONAL { ?tax mpo:MPO_10003/rdfs:label ?temp_range_label  FILTER (lang(?temp_range_label) = "en") .}
          OPTIONAL { ?tax mpo:MPO_10002/rdfs:label ?oxy_req_label FILTER (lang(?oxy_req_label) = "en") .}
          OPTIONAL { ?tax mpo:MPO_10009 ?opt_temp .}
          OPTIONAL { ?tax mpo:MPO_10010 ?min_temp .}
          OPTIONAL { ?tax mpo:MPO_10011 ?max_temp .}
          OPTIONAL { ?tax mpo:MPO_10005 ?opt_ph .}
          OPTIONAL { ?tax mpo:MPO_10006 ?min_ph .}
          OPTIONAL { ?tax mpo:MPO_10007 ?max_ph .}
          ?taxon rdfs:label ?organism_name
        } GROUP BY ?tax ?organism_name ?genome_length  ?bioProject  ?opt_temp ?min_temp ?max_temp ?opt_ph ?min_ph ?max_ph
      SPARQL
    }

    #gene #rrna #trna
    query3 = Thread.new {
      summary_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
        SELECT ?tax ?project_id ?num_gene ?num_rrna ?num_trna
        FROM <http://togogenome.org/refseq_gene_count/>
        WHERE
        {
         ?tax <gene_count> ?blank .
         ?blank rdfs:seeAlso ?project_id .
         ?blank <gene_number> ?num_gene .
         ?blank <rrna_number> ?num_rrna .
         ?blank <trna_number> ?num_trna .
        }
      SPARQL
    }

    query4 = Thread.new {
      pfam_summary_list = query('http://biointegra.jp/sparql3',<<-SPARQL.strip_heredoc)
        PREFIX up: <http://purl.uniprot.org/core/>
        PREFIX tax: <http://purl.uniprot.org/taxonomy/>
        PREFIX pfam: <http://purl.uniprot.org/pfam/>
 
        SELECT
          REPLACE(STR(?tax), "http://purl.uniprot.org/taxonomy/", "http://identifiers.org/taxonomy/") AS ?tax_id
          (SUM(?hits) as ?num_pfam)
          (COUNT(DISTINCT(?prot_id)) AS ?num_pfam_protein)
        FROM <http://togogenome.org/uniprot/>
        WHERE
        {
          ?prot_id up:organism ?tax .
          ?prot_id rdfs:seeAlso pfam:#{pfam_id} .
          ?id rdf:subject ?prot_id .
          ?id rdf:object pfam:#{pfam_id} .
          ?id up:hits ?hits .
        } GROUP BY ?tax
      SPARQL
    }
    query1.join
    query2.join
    query3.join
    query4.join

    #habitat
    habitat_hash = {}
    habitat_list.each do |entity|
      habitat_hash[entity[:tax]] = entity[:habitat].split(", ").sort.join(", ")
    end
    habitat_list = nil

    #gene #rrna #trna
    gene_hash ={}
    rrna_hash ={}
    trna_hash ={}
    summary_list.each do |entity|
      gene_hash[entity[:tax] + "/" + entity[:project_id]] = entity[:num_gene]
      rrna_hash[entity[:tax] + "/" + entity[:project_id]] = entity[:num_rrna]
      trna_hash[entity[:tax] + "/" + entity[:project_id]] = entity[:num_trna]
    end
    summary_list = nil

    pfam_hash ={}
    pfam_protein_hash ={}
    pfam_summary_list.each do |entity|
      pfam_hash[entity[:tax_id]] = entity[:num_pfam]
      pfam_protein_hash[entity[:tax_id]] = entity[:num_pfam_protein]
    end
    pfam_summary_list = nil

    ##merge all data
    result_list = []
    result_list = genome_list.map {|hash|
      tax_prj_key = hash[:tax] + "/" + hash[:bioProject]
      habitat_label = habitat_hash.key?(hash[:tax]) ? habitat_hash[hash[:tax]] :'no data'
      gene = gene_hash.key?(tax_prj_key) ? gene_hash[tax_prj_key] : '0'
      rrna = rrna_hash.key?(tax_prj_key) ? rrna_hash[tax_prj_key] : '0'
      trna = trna_hash.key?(tax_prj_key) ? trna_hash[tax_prj_key] : '0'
      pfam = pfam_hash.key?(hash[:tax]) ? pfam_hash[hash[:tax]] : '0'
      pfam_protein = pfam_protein_hash.key?(hash[:tax]) ? pfam_protein_hash[hash[:tax]] : '0'
      hash.merge(
        :habitat => habitat_label,
        :num_gene => gene,
        :num_rrna => rrna,
        :num_trna => trna,
        :num_pfam => pfam,
        :num_pfam_protein => pfam_protein,
        :size => hash[:genome_length]
      ) 
    }
    result_list.delete_if {|entity| entity[:num_gene] == '0'}

    result_list
  end
end
