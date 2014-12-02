class OrganismGenomeSizeNanoStanza < TogoStanza::Stanza::Base
  property :genome_size do |tax_id|
   result = query('http://togostanza.org/sparql', <<-SPARQL.strip_heredoc)
     PREFIX ddbj:<http://ddbj.nig.ac.jp/ontologies/sequence#>
     PREFIX obo:<http://purl.obolibrary.org/obo/>
     PREFIX taxid:<http://identifiers.org/taxonomy/>

     SELECT (COUNT(?bioproject_id) AS ?project_num) (SUM(?seq_length) AS ?all_project_length)
     FROM <http://togogenome.org/graph/refseq/>
     WHERE
     {
       {
         SELECT ?bioproject_id (SUM(?length) AS ?seq_length)
         {
           ?seq rdfs:seeAlso taxid:#{tax_id} .
           ?seq rdf:type ?type FILTER ( ?type IN(obo:SO_0000155, obo:SO_0000340)) .
           ?seq rdfs:seeAlso ?bioproject_id .
           ?bioproject_id rdf:type <http://identifiers.org/bioproject/> .
           ?seq ddbj:sequence_length ?length .
         } GROUP BY ?bioproject_id
       }
     }
   SPARQL
 
   if result == nil || result.first[:project_num].to_i == 0 then
     result = nil
     next
   end

   genome_size = (result.first[:all_project_length].to_f / result.first[:project_num].to_f).round

   if genome_size >= 10**9
     mantissa = (genome_size / (10**9).to_f).round(1)
     unit = "Gb"
   elsif genome_size >= 10**6
     mantissa = (genome_size / (10**6).to_f).round(1)
     unit = "Mb"
   elsif genome_size >= 10**3
     mantissa = (genome_size / (10**3).to_f).round(1)
     unit = "Kb"
   else
     mantissa = genome_size 
     unit = "b"
   end

   ret = { :genome_size => genome_size, :mantissa => mantissa, :unit => unit }
   ret
  end
end
