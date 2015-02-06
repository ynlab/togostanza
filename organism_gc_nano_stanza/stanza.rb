require 'open-uri'

class OrganismGcNanoStanza < TogoStanza::Stanza::Base
  property :title do
    "GC%"
  end

  property :atgc do |tax_id|
    # http://localhost:9292/stanza/organism_gc_nano?tax_id=192222

    results = query('http://dev.togogenome.org/sparql-test', <<-SPARQL.strip_heredoc)
      PREFIX taxid:<http://identifiers.org/taxonomy/>
      PREFIX stats: <http://togogenome.org/stats/>
      PREFIX ddbj: <http://ddbj.nig.ac.jp/ontologies/nucleotide/>

      SELECT ?refseq
      WHERE
      {
        GRAPH <http://togogenome.org/graph/stats> {
           taxid:#{tax_id} rdfs:seeAlso/rdfs:seeAlso ?refseq_id .
        }
        GRAPH <http://togogenome.org/graph/refseq> {
          ?refseq_id rdf:type ddbj:Entry ;
            ddbj:sequence_version ?refseq .
        }
      }
    SPARQL

    count = results.inject({at: 0, gc: 0}) do |result, res|
      # {:refseq=>"NC_002163.1"}
      seq = open("http://togows.org/entry/nucleotide/#{res[:refseq]}/seq").read

      result[:at] += seq.count('a') + seq.count('t')
      result[:gc] += seq.count('g') + seq.count('c')
      result
    end



    unless (sum = count[:gc] + count[:at]).zero?
      {
        gc_percentage: calc_percent(count[:gc], sum) ,
        at_percentage: calc_percent(count[:at], sum)
      }
    else
      nil
    end
  end

  def calc_percent(val, sum)
    (val.to_f / sum.to_f * 100.0).to_i
  end
end
