class FeatureLocationStanza < TogoStanza::Stanza::Base
  
  property :params do
       params
  end

#  resource :sequence do |dataset, entry_id, seq_id, position_begin, position_end|
  property :sequence_t do |dataset, entry_id, seq_id, position_begin, position_end|
      require 'bio'
      require 'open-uri'
      url = "http://togows.dbcls.jp/entry/nucleotide/#{seq_id}.fasta"
      fasta_string = URI.parse(url).read
      #result = JSON.parse(json)
      fasta = Bio::FastaFormat.new(fasta_string)
      dna = Bio::Sequence.auto(fasta.data)
      dna.subseq(position_begin.to_i ,position_end.to_i).to_fasta("#{seq_id}:#{position_begin}..#{position_end}",100)
      #dna.subseq(position_begin.to_i ,position_end.to_i).scan(/.{1,#{100}}/).join("\n")
      #Bio::FlatFile.auto(fasta)
      #open(url) do |file|
      #      puts file.read
      #end
  end

  property :sequence do |dataset, entry_id, seq_id, position_begin, position_end|
   results = query("http://staging-genome.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
#DEFINE sql:select-option "order"
prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd:    <http://www.w3.org/2001/XMLSchema#>
prefix obo:    <http://purl.obolibrary.org/obo/>
prefix faldo:  <http://biohackathon.org/resource/faldo#>
prefix idorg:  <http://rdf.identifiers.org/database/>
PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>

SELECT
IF(?fstart < ?fend , ?fstart, ?fend) as ?start,IF(?fstart < ?fend , ?fend, ?fstart) as ?end
,IF( ?faldo_type = faldo:ForwardStrandPosition, '+', IF( ?faldo_type = faldo:ReverseStrandPosition,'-','.')) as ?strand
,str(?obj_type) as ?type,
str(?label) as ?name,
str(?obj_name) as ?description
, str(?obj) as ?uniqueID
FROM <http://genome.microbedb.jp/resources/cyanobase/genbank>
WHERE {
#values ?entry { <http://identifiers.org/insdc/CACA01000081.1>}

values ?faldo_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition faldo:BothStrandsPosition }
?entry insdc:sequence_version ?seq_version.
BIND(STRBEFORE(?seq_version,".") as ?seq_acc).

#filter(?seq_acc = "CACA01000081")
#filter(?seq_acc = "{ref}")
filter(?seq_acc = "#{seq_id.partition(".").first}")

?entry insdc:sequence ?seq.
?obj obo:so_part_of+  ?seq .
?obj rdf:type ?obj_type .
?obj faldo:location ?faldo .
?faldo faldo:begin/rdf:type ?faldo_type .
?faldo faldo:begin/faldo:position ?fstart .
?faldo faldo:end/faldo:position ?fend .
?obj obo:so_part_of ?parent . filter( ?obj_type = obo:SO_0000704 || ?parent != ?seq )

optional {?obj insdc:locus_tag ?label .}
optional {?obj insdc:product ?obj_name .}

#filter ( !(?start > {end} || ?end < {start}) )
#filter ( !(?start > #{position_end} || ?end < #{position_begin}) )
#filter ( !(?start > 1 || ?end < 10000) )
filter ((#{position_begin} <= ?fstart && ?fstart <= #{position_end} ) || (#{position_begin} <= ?fend && ?fend <= #{position_end}))
}
ORDER BY ?start
SPARQL
   
   url = "http://togows.dbcls.jp/entry/nucleotide/#{seq_id}/seq/#{position_begin}..#{position_end}"
   subseq = URI.parse(url).read.chomp.upcase
   #results.each do |v|
   #    subseq.insert(v[:start].to_i - position_begin.to_i, "<span id=\"#{v[:name]}\" style=\"font-color:red;\">")
   #    subseq.insert(v[:end].to_i - position_begin.to_i, "</span>")
   #end
   subseq
  end

  resource :features do |dataset, entry_id, seq_id, position_begin, position_end|
   results = query("http://staging-genome.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
      
#DEFINE sql:select-option "order"
prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd:    <http://www.w3.org/2001/XMLSchema#>
prefix obo:    <http://purl.obolibrary.org/obo/>
prefix faldo:  <http://biohackathon.org/resource/faldo#>
prefix idorg:  <http://rdf.identifiers.org/database/>
PREFIX insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>

SELECT
IF(?fstart < ?fend , ?fstart, ?fend) as ?start,IF(?fstart < ?fend , ?fend, ?fstart) as ?end
,IF( ?faldo_type = faldo:ForwardStrandPosition, '+', IF( ?faldo_type = faldo:ReverseStrandPosition,'-','.')) as ?strand
,str(?obj_type) as ?type,
str(?label) as ?name,
str(?obj_name) as ?description
, str(?obj) as ?uniqueID
FROM <http://genome.microbedb.jp/resources/cyanobase/genbank>
WHERE {
#values ?entry { <http://identifiers.org/insdc/CACA01000081.1>}

values ?faldo_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition faldo:BothStrandsPosition }
?entry insdc:sequence_version ?seq_version.
BIND(STRBEFORE(?seq_version,".") as ?seq_acc).

#filter(?seq_acc = "CACA01000081")
#filter(?seq_acc = "{ref}")
filter(?seq_acc = "#{seq_id.partition(".").first}")

?entry insdc:sequence ?seq.
?obj obo:so_part_of+  ?seq .
?obj rdf:type ?obj_type .
?obj faldo:location ?faldo .
?faldo faldo:begin/rdf:type ?faldo_type .
?faldo faldo:begin/faldo:position ?fstart .
?faldo faldo:end/faldo:position ?fend .
?obj obo:so_part_of ?parent . filter( ?obj_type = obo:SO_0000704 || ?parent != ?seq )

optional {?obj insdc:locus_tag ?label .}
optional {?obj insdc:product ?obj_name .}

#filter ( !(?start > {end} || ?end < {start}) )
#filter ( !(?start > #{position_end} || ?end < #{position_begin}) )
#filter ( !(?start > 1 || ?end < 10000) )
filter ((#{position_begin} <= ?fstart && ?fstart <= #{position_end} ) || (#{position_begin} <= ?fend && ?fend <= #{position_end}))
}
ORDER BY ?start
SPARQL
  end
end
