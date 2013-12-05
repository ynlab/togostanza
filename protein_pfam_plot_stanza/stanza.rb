class ProteinPfamPlotStanza < TogoStanza::Stanza::Base
  property :pfam_list do |tax_id,gene_id|
    results = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT (REPLACE(STR(?ref), "http://purl.uniprot.org/pfam/","") AS ?pfam_id)
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE
      {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a <http://purl.uniprot.org/core/Protein> ;
          rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:abbreviation ?abbr
        FILTER (?abbr ='Pfam').
      }
    SPARQL

    if results == nil || results.size == 0 then
      next nil
    end
    pfam_list = []
    results.each do |entity|
      pfam_hash = {}
      pfam_id = entity[:pfam_id]
      pfam_name_list =  query("http://ep.dbcls.jp/sparql7ssd", <<-SPARQL.strip_heredoc)
        PREFIX pfam: <http://purl.uniprot.org/pfam/>

        SELECT ?label
        WHERE
        {
          pfam:#{pfam_id} rdfs:comment ?label .
        }
      SPARQL
      pfam_hash[:id] = pfam_id
      if pfam_name_list == nil || pfam_name_list.size == 0 then
        pfam_hash[:name] = ''
      else
        pfam_hash[:name] = pfam_name_list[0][:label]
      end
      pfam_list.push(pfam_hash)
    end
    pfam_list
  end

  property :selected_tax_id do |tax_id|
    tax_id
  end

  property :selected_gene_id do |gene_id|
    gene_id
  end

  resource :plot_data do |tax_id,gene_id|
     habitat_list =[]
     summary_list = []
     genome_list = []
     pfam_list = []
     pfam_summary_list = []

    pfam_list = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"
      PREFIX up: <http://purl.uniprot.org/core/>
      PREFIX taxonomy: <http://purl.uniprot.org/taxonomy/>

      SELECT DISTINCT (REPLACE(STR(?ref), "http://purl.uniprot.org/pfam/","") AS ?pfam_id)
      FROM <http://togogenome.org/graph/uniprot/>
      FROM <http://togogenome.org/graph/tgup/>
      WHERE
      {
        <http://togogenome.org/gene/#{tax_id}:#{gene_id}> ?p ?id_upid .
        ?id_upid rdfs:seeAlso ?protein .
        ?protein a <http://purl.uniprot.org/core/Protein> ;
          rdfs:seeAlso ?ref .
        ?ref up:database ?database .
        ?database up:abbreviation ?abbr
        FILTER (?abbr ='Pfam').
      }
    SPARQL

    if pfam_list == nil || pfam_list.size == 0 then
      pfam_list = []
      next
    end

    query1 = Thread.new {
      habitat_list = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
        PREFIX owl: <http://www.w3.org/2002/07/owl#>
        PREFIX meo: <http://purl.jp/bio/11/meo/>
        PREFIX mccv: <http://purl.jp/bio/01/mccv#>

        SELECT ?tax ((sql:GROUP_DIGEST (?label, ', ', 1000, 1)) AS ?habitat)
        FROM <http://togogenome.org/graph/gold/>
        FROM <http://togogenome.org/graph/meo/>
        WHERE
        {
          VALUES ?p_env { meo:MEO_0000437 meo:MEO_0000440 }
          ?gold mccv:MCCV_000020 ?tax FILTER regex(?tax, "^http://identifiers.org/") .
          ?gold ?p_env ?meo .
          ?meo a owl:Class ;
            rdfs:subClassOf* ?parent .
            ?parent rdfs:label ?label .
          ?parent meo:MEO_0000442 "1" .
        } GROUP BY ?tax
      SPARQL
    }

    query2 = Thread.new {
      genome_list = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
        DEFINE sql:select-option "order"
        PREFIX owl: <http://www.w3.org/2002/07/owl#>
        PREFIX mccv: <http://purl.jp/bio/01/mccv#>
        PREFIX mpo:<http://purl.jp/bio/01/mpo#>
        PREFIX obo: <http://purl.obolibrary.org/obo/>
        PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/sequence#>
        PREFIX taxo: <http://ddbj.nig.ac.jp/ontologies/taxonomy#>

        SELECT
          ?tax ?organism_name ?bioProject ?genome_length
          ((sql:GROUP_DIGEST (?cell_shape_label, ', ', 1000, 1)) AS ?cell_shape_label)
          ((sql:GROUP_DIGEST (?temp_range_label, ', ', 1000, 1)) AS ?temp_range_label)
          ((sql:GROUP_DIGEST (?oxy_req_label, ', ', 1000, 1)) AS ?oxy_req_label)
          ?opt_temp ?min_temp ?max_temp ?opt_ph ?min_ph ?max_ph
        FROM <http://togogenome.org/graph/refseq/>
        FROM <http://togogenome.org/graph/mpo/>
        FROM <http://togogenome.org/graph/gold/>
        FROM <http://togogenome.org/graph/taxonomy/>
        {
          {
            SELECT ?tax ?bioProject (SUM(?seq_len) AS ?genome_length)
            {
              ?tax rdf:type <http://identifiers.org/taxonomy/> .
              ?seq rdfs:seeAlso ?tax ;
              rdf:type ?obo_type FILTER(?obo_type IN (obo:SO_0000340, obo:SO_0000155 )) .
              ?seq insdc:sequence_length ?seq_len ;
                rdfs:seeAlso ?bioProject .
              ?bioProject rdf:type <http://identifiers.org/bioproject/> .
            } GROUP BY ?tax  ?bioProject
          }
          OPTIONAL { ?tax mpo:MPO_10001/rdfs:label ?cell_shape_label  FILTER (lang(?cell_shape_label) = "en") . }
          OPTIONAL { ?tax mpo:MPO_10003/rdfs:label ?temp_range_label  FILTER (lang(?temp_range_label) = "en") . }
          OPTIONAL { ?tax mpo:MPO_10002/rdfs:label ?oxy_req_label FILTER (lang(?oxy_req_label) = "en") . }
          OPTIONAL { ?tax mpo:MPO_10009 ?opt_temp . }
          OPTIONAL { ?tax mpo:MPO_10010 ?min_temp . }
          OPTIONAL { ?tax mpo:MPO_10011 ?max_temp . }
          OPTIONAL { ?tax mpo:MPO_10005 ?opt_ph . }
          OPTIONAL { ?tax mpo:MPO_10006 ?min_ph . }
          OPTIONAL { ?tax mpo:MPO_10007 ?max_ph . }
          ?tax taxo:scientificName ?organism_name
        } GROUP BY ?tax ?organism_name ?genome_length ?bioProject  ?opt_temp ?min_temp ?max_temp ?opt_ph ?min_ph ?max_ph
      SPARQL
    }

    #gene #rrna #trna
    query3 = Thread.new {
      summary_list = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
        DEFINE sql:select-option "order"
        PREFIX togo: <http://togogenome.org/stats/>

        SELECT ?tax ?project_id ?num_gene ?num_rrna ?num_trna
        FROM <http://togogenome.org/graph/stats/>
        FROM <http://togogenome.org/graph/refseq/>
        WHERE
        {
          ?project_id a <http://identifiers.org/bioproject/> .
          ?tax rdfs:seeAlso ?project_id .
          ?tax a <http://identifiers.org/taxonomy/> .
          ?project_id togo:gene ?num_gene .
          ?project_id togo:rrna ?num_rrna .
          ?project_id togo:trna ?num_trna.
        }
      SPARQL
    }

    query1.join
    query2.join
    query3.join

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

    result_hash = {}
    pfam_list.each do |pfam_entity|
      pfam_id = pfam_entity[:pfam_id]
      pfam_summary_list = query("http://ep.dbcls.jp/sparql7ssd",<<-SPARQL.strip_heredoc)
        PREFIX up: <http://purl.uniprot.org/core/>
        PREFIX tax: <http://purl.uniprot.org/taxonomy/>
        PREFIX pfam: <http://purl.uniprot.org/pfam/>

        SELECT
          (REPLACE(STR(?tax), "http://purl.uniprot.org/taxonomy/", "http://identifiers.org/taxonomy/") AS ?tax_id)
          ((SUM(?hits) AS ?num_pfam))
          (COUNT(DISTINCT(?prot_id)) AS ?num_pfam_protein)
        FROM <http://togogenome.org/graph/uniprot/>
        WHERE
        {
          ?prot_id up:organism ?tax .
          ?prot_id rdfs:seeAlso pfam:#{pfam_id} .
          ?id rdf:subject ?prot_id .
          ?id rdf:object pfam:#{pfam_id} .
          ?id up:hits ?hits .
        } GROUP BY ?tax
      SPARQL

      pfam_hash ={}
      pfam_protein_hash ={}
      pfam_summary_list.each do |entity|
        pfam_hash[entity[:tax_id]] = entity[:num_pfam]
        pfam_protein_hash[entity[:tax_id]] = entity[:num_pfam_protein]
      end
      pfam_summary_list = nil

      ##merge all data
      tax_list = []
      tax_list = genome_list.map {|hash|
        tax_prj_key = hash[:tax] + "/" + hash[:bioProject]
        habitat_label = habitat_hash.key?(hash[:tax]) ? habitat_hash[hash[:tax]] :'no data'
        gene = gene_hash.key?(tax_prj_key) ? gene_hash[tax_prj_key] : '0'
        rrna = rrna_hash.key?(tax_prj_key) ? rrna_hash[tax_prj_key] : '0'
        trna = trna_hash.key?(tax_prj_key) ? trna_hash[tax_prj_key] : '0'
        pfam = pfam_hash.key?(hash[:tax]) ? pfam_hash[hash[:tax]] : '0'
        pfam_protein = pfam_protein_hash.key?(hash[:tax]) ? pfam_protein_hash[hash[:tax]] : '0'
        hash.merge(
          habitat: habitat_label,
          num_gene: gene,
          num_rrna: rrna,
          num_trna: trna,
          num_pfam: pfam,
          num_pfam_protein: pfam_protein,
          size: hash[:genome_length]
        )
      }
      tax_list.delete_if {|entity| entity[:num_gene] == '0'}
      result_hash[pfam_id] = tax_list
    end
    [result_hash]
  end
end
