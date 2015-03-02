class OrganismGeneListStanza < TogoStanza::Stanza::Base
  property :organism_gene_list do |tax_id|

    endpoint = "http://dev.togogenome.org/sparql-test"
    end_reactome = "http://www.ebi.ac.uk/rdf/services/reactome/sparql"

    ### gene - gene name, position, etc.
    result = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      SELECT ?gene ?gene_id ?gene_name (REPLACE( STR(?gene_id), ":.+$", "") AS ?seq) ?begin
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/refseq>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> ;
              skos:exactMatch ?refseq_gene .
        ?refseq_gene a insdc:Gene ;
                     rdfs:label ?gene_name ;
                     faldo:location/faldo:begin/faldo:position ?begin .
        BIND (REPLACE( STR(?gene), "http://togogenome.org/gene/", "") AS ?gene_id)
      }
      ORDER BY ?seq ?begin
    SPARQL

    next if result.nil?

    ### gene - pseudogene
    gene_pseudo = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX faldo: <http://biohackathon.org/resource/faldo#>
      SELECT ?gene
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/refseq>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> ;
              skos:exactMatch ?refseq_gene .
        ?refseq_gene a insdc:Gene ;
                     insdc:pseudo true .
      }
    SPARQL

    gene2pseudo = {}
    gene_pseudo.each{|data|
      gene2pseudo[data[:gene]] = 1
    }

    ### gene - tRNA, ncRNA
    gene_rna_product = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      SELECT ?gene ?product
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/refseq>
      FROM <http://togogenome.org/graph/uniprot>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> ;
              skos:exactMatch ?refseq_gene .
        ?rna obo:so_part_of ?refseq_gene .
        FILTER( REGEX(?rna, "tRNA") || REGEX(?rna, "ncRNA"))
        ?rna insdc:product ?product .
        FILTER(! REGEX(?product, "uncharacterized", "i"))
      }
    SPARQL

    gene2rna_product = {}
    gene_rna_product.each{|data|
      gene2rna_product[data[:gene]] = [] unless gene2rna_product[data[:gene]]
      gene2rna_product[data[:gene]].push(data[:product])
    }

    ### gene - citation
    gene_citation = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      SELECT ?gene (COUNT(DISTINCT ?cite) AS ?citation) 
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/uniprot>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> .
        FILTER( REGEX(?gene, "http://togogenome.org/gene/"))
        ?gene rdfs:seeAlso/rdfs:seeAlso/up:citation ?cite .
        ?cite a up:Journal_Citation .
      }
    SPARQL

    gene2citation = {}
    gene_citation.each{|data|
      gene2citation[data[:gene]] = data[:citation] if data[:citation]
    }

    ### gene - reactome root name
    # get reactome graph name
    reactome_graph = query("#{end_reactome}", <<-SPARQL.strip_heredoc).first
      SELECT DISTINCT ?graph
      WHERE { GRAPH ?graph { ?s a <http://www.biopax.org/release/biopax-level3.owl#Pathway> . }}
    SPARQL

    graph = reactome_graph[:graph]

    # reactome_id - reactome root name
    reactome = query("#{end_reactome}", <<-SPARQL.strip_heredoc)
      PREFIX bpx: <http://www.biopax.org/release/biopax-level3.owl#>
      SELECT DISTINCT (REPLACE( STR(?reactome), "http://identifiers.org/reactome/", "") AS ?reactome_id) ?parent_name
      FROM <#{graph}>
      WHERE {
        ?reactome a bpx:Pathway .
        ?parent bpx:pathwayComponent+ ?reactome .
        OPTIONAL { ?root bpx:pathwayComponent ?parent . }
        FILTER(! REGEX(?root, "reactome"))
        ?parent  bpx:displayName ?parent_name .    
      }
    SPARQL

    reactome2root_name = {}
    reactome.each{|data|
      react_id = data[:reactome_id].split("\.").first
      reactome2root_name[react_id] = [] unless reactome2root_name[react_id]
      reactome2root_name[react_id].push(data[:parent_name])
    }

    # gene - reactome_id
    gene_reactome = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      SELECT ?gene (REPLACE( STR(?reactome), "http://purl.uniprot.org/reactome/", "") AS ?reactome_id)
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/uniprot>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> .
        FILTER( REGEX(?gene, "http://togogenome.org/gene/"))
        ?gene rdfs:seeAlso/rdfs:seeAlso/rdfs:seeAlso ?reactome .
        ?reactome up:database <http://purl.uniprot.org/database/Reactome> .
      }
    SPARQL

    gene2reactome = {}
    gene_reactome.each{|data|
      if data[:reactome_id] && reactome2root_name[data[:reactome_id]]
        gene2reactome[data[:gene]] = [] unless gene2reactome[data[:gene]]
        gene2reactome[data[:gene]] += reactome2root_name[data[:reactome_id]]
      end
    }

    ### gene - protein name, ec
    gene_protein = query("#{endpoint}", <<-SPARQL.strip_heredoc)
      PREFIX up: <http://purl.uniprot.org/core/>
      SELECT DISTINCT ?gene ?protein_name ?ec_name
      FROM <http://togogenome.org/graph/tgup>
      FROM <http://togogenome.org/graph/uniprot>
      WHERE {
        ?gene rdfs:seeAlso <http://identifiers.org/taxonomy/#{tax_id}> .
         FILTER( REGEX(?gene, "http://togogenome.org/gene/"))
        ?gene rdfs:seeAlso/rdfs:seeAlso ?protein .
        ?protein a up:Protein ;
                 up:recommendedName ?recommended_name_node .
        ?recommended_name_node up:fullName ?protein_name . 

        OPTIONAL { ?recommended_name_node up:ecName ?ec_name . }
      }
    SPARQL

    gene2protein = {}
    gene2ec = {}
    gene_protein.each{|data|
      if data[:protein_name]
        gene2protein[data[:gene]] = [] unless gene2protein[data[:gene]]
        gene2protein[data[:gene]].push(data[:protein_name]) 
      end
     if data[:ec_name]
        gene2ec[data[:gene]] = [] unless gene2ec[data[:gene]]
        gene2ec[data[:gene]].push(data[:ec_name]) 
      end
    }

    result.each{|data|
      if gene2pseudo[data[:gene]]
        data.delete(:gene_id)
        data[:gene_name] += " (pseudo)"
      end 
      data[:citation] = gene2citation[data[:gene]] if gene2citation[data[:gene]]
      data[:ec] = gene2ec[data[:gene]].uniq.join(", ") if gene2ec[data[:gene]]
      data[:reactome] =  gene2reactome[data[:gene]].uniq if gene2reactome[data[:gene]]
       if gene2protein[data[:gene]]
         data[:attr] = gene2protein[data[:gene]].uniq.join(", ")
       elsif gene2rna_product[data[:gene]]
         data[:attr] = gene2rna_product[data[:gene]].uniq.join(", ")
       end
    }
  end
end
