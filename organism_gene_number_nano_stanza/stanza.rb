class OrganismGeneNumberNanoStanza < TogoStanza::Stanza::Base
  property :genome_stats do |tax_id|
    result = query('http://togostanza.org/sparql', <<-SPARQL.strip_heredoc).first
      PREFIX tgstat:<http://togogenome.org/stats/>
      PREFIX taxid:<http://identifiers.org/taxonomy/>

      SELECT DISTINCT ?project_num ?gene_num ?rrna_num ?trna_num ?ncrna_num
      FROM <http://togogenome.org/graph/stats/>
      WHERE
      {
        taxid:#{tax_id} tgstat:bioproject ?project_num ;
        tgstat:gene ?gene_num ;
        tgstat:rrna ?rrna_num ;
        tgstat:trna ?trna_num ;
        tgstat:ncrna ?ncrna_num .
      }
    SPARQL

    next if result.nil?

    gene_number  = (result[:gene_num].to_f / result[:project_num].to_f).round
    rrna_number  = (result[:rrna_num].to_f / result[:project_num].to_f).round
    trna_number  = (result[:trna_num].to_f / result[:project_num].to_f).round
    ncrna_number = (result[:ncrna_num].to_f / result[:project_num].to_f).round

    {
      gene_number:  gene_number,
      rrna_number:  rrna_number,
      trna_number:  trna_number,
      ncrna_number: ncrna_number
    }
  end
end
