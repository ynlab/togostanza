require 'bio-svgenes'
require 'pp'

class GeneViewStanza < Stanza::Base
  property :gene do |tax_id, gene_id|
    genes = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
      prefix xsd:    <http://www.w3.org/2001/XMLSchema#>
      prefix obo:    <http://purl.obolibrary.org/obo/>
      prefix faldo:  <http://biohackathon.org/resource/faldo#>
      prefix idorg:  <http://rdf.identifiers.org/database/>
      prefix insdc:  <http://insdc.org/owl/>

      select distinct
        ?locus_tag
        (str(?gene_type_label) as ?gene_type_label)
        ?gene_label
        ?gene_symbol
        ?insdc_location
        ?faldo_begin_position
        ?faldo_end_position
        (?faldo_begin_type as ?strand)
        (str(?strand_label) as ?strand_label) #strand from ?faldo_begin_type
        ?faldo_type
        (str(?faldo_type_label) as ?faldo_type_label)
        ((xsd:int(?faldo_end_position) - xsd:int(?faldo_begin_position) +1) as ?gene_length)
        ?seq_label
        ?seq_type
        (str(?seq_type_label) as ?seq_type_label)
        ?refseq_label
        ?ncbi_taxid
        ?organism
        ?seq
      from <http://togogenome.org/refseq/>
      from <http://togogenome.org/so/>
      from <http://togogenome.org/faldo/>
      where {
        values ?locus_tag { "#{gene_id}" }  # param "slr0473"
        #values ?ncbi_taxid {"#{tax_id}" }  # param "taxon:1148"
        values ?seq_type  { obo:SO_0000340 obo:SO_0000155 } # chromosome, plasmid
        values ?gene_type { obo:SO_0000316 obo:SO_0000252 obo:SO_0000253 } # CDS, rRNA, tRNA
        values ?faldo_begin_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition }

        # gene
        ?gene insdc:feature_locus_tag ?locus_tag.
        ?gene a ?gene_type.
        ?gene_type rdfs:label ?gene_type_label.

        # gene label
        ?gene rdfs:label ?gene_label.
        OPTIONAL { ?gene insdc:feature_gene ?gene_symbol. }

        # seq
        ?gene obo:so_part_of+ ?seq.
        ?seq rdfs:label ?seq_label.
        ?seq a ?seq_type.
        ?seq_type rdfs:label ?seq_type_label.
        ?seq rdfs:seeAlso ?refseq .
        ?refseq a idorg:RefSeq .
        ?refseq rdfs:label ?refseq_label .
        ?seq insdc:source_organism ?organism .

        # taxonomy ncbi
        ?seq rdfs:seeAlso ?taxonomy .
        ?taxonomy a idorg:Taxonomy .
        ?taxonomy rdfs:label ?ncbi_taxid .

        # faldo
        ?gene faldo:location ?faldo.
        ?faldo insdc:location ?insdc_location.

        ?faldo faldo:begin ?faldo_begin.
        ?faldo_begin faldo:position ?faldo_begin_position.
        ?faldo_begin rdf:type ?faldo_begin_type.
        ?faldo_begin_type rdfs:label ?strand_label.

        ?faldo faldo:end ?faldo_end.
        ?faldo_end faldo:position ?faldo_end_position.
        ?faldo_end rdf:type ?faldo_end_type.
        ?faldo rdf:type ?faldo_type.
        ?faldo_type rdfs:label ?faldo_type_label.
      }
    SPARQL
    pp genes

    gene = genes.first
    offset = 2000
    s = gene[:seq]
    f = gene[:faldo_begin_position].to_i - offset
    t = gene[:faldo_end_position].to_i + offset

    results = query("http://ep.dbcls.jp/sparql", <<-SPARQL.strip_heredoc)
      DEFINE sql:select-option "order"

      prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
      prefix xsd:    <http://www.w3.org/2001/XMLSchema#>
      prefix obo:    <http://purl.obolibrary.org/obo/>
      prefix faldo:  <http://biohackathon.org/resource/faldo#>
      prefix idorg:  <http://rdf.identifiers.org/database/>
      prefix insdc:  <http://insdc.org/owl/>

      select *
      from <http://togogenome.org/refseq/>
      from <http://togogenome.org/so/>
      from <http://togogenome.org/faldo/>
      where {
        values ?faldo_type { faldo:ForwardStrandPosition faldo:ReverseStrandPosition }
        ?obj obo:so_part_of+ <#{s}> .

        ?obj faldo:location ?faldo .
        ?faldo faldo:begin/rdf:type ?faldo_type .
        ?faldo_type rdfs:label ?strand .
        ?faldo faldo:begin/faldo:position ?b .
        ?faldo faldo:end/faldo:position ?e .
        filter ((#{f} < ?e && ?e < #{t}) || (#{f} < ?b && ?e < #{t}) || (#{f} < ?b && ?b < #{t}))

        ?obj rdf:type ?obj_type .
        ?obj_type rdfs:label ?obj_label .
        filter (?obj_type != obo:SO_0000704)  # gene
        optional {
          ?obj insdc:feature_locus_tag ?label .
        }
        optional {
          ?obj insdc:feature_product ?obj_name .
          #?obj insdc:feature_product|insdc:feature_gene ?obj_name .
        }
        #optional {
        #  ?obj rdfs:seeAlso ?obj_seealso .
        #}

        optional {
          ?obj obo:so_has_part/rdf:rest*/rdf:first ?part .
          ?part faldo:begin/faldo:position ?pb .
          ?part faldo:end/faldo:position ?pe .
        }
      }
      order by ?b
    SPARQL
    objs = results.group_by {|h| h[:obj]}
    pp objs

    page = Bio::Graphics::Page.new(
      :width => 800, 
      :height => 200, 
      :number_of_intervals => 3,
    )

    gene_track = nil
    rrna_track = nil
    trna_track = nil
    other_track = nil

    objs.each do |k, gene|
      exons = []
      param = {}

      gene.each do |exon|
        param[:id] = exon[:label]
        param[:type] = exon[:obj_label]
        param[:start] = exon[:b].to_i
        param[:end] = exon[:e].to_i
        case exon[:strand]
        when 'Positive strand'
          param[:strand] = '+'
        else
          param[:strand] = '-'
        end
        if exon[:pb] and exon[:pe]
          exons << [exon[:pb].to_i, exon[:pe].to_i]
        else
          exons << [exon[:b].to_i, exon[:e].to_i]
        end
      end

      obj = Bio::Graphics::MiniFeature.new(
        :id => param[:id],
        :start => param[:start],
        :end => param[:end],
        :strand => param[:strand],
        :exons => exons.sort_by{|x| x.first}.flatten,
      )

      case param[:type]
      when "CDS"
        unless gene_track
          gene_track = page.add_track(
            :glyph => :transcript,
            :name => 'protein coding gene',
            :feature_height => 20,
            :exon_fill_color => :blue_white_h,
            :utr_fill_color => :red_white_h,
            :gap_marker => 'angled',
          )
        end
        gene_track.add(obj)
      when "rRNA"
        unless rrna_track
          rrna_track = page.add_track(
            :glyph => :transcript,
            :name => 'rRNA gene',
            :feature_height => 20,
            :line_width => 0,
            :exon_fill_color => :green_white_h,
            :utr_fill_color => :red_white_h,
            :gap_marker => 'angled',
          )
        end
        rrna_track.add(obj)
      when "tRNA"
        unless trna_track
          trna_track = page.add_track(
            :glyph => :transcript,
            :name => 'tRNA gene',
            :feature_height => 20,
            :line_width => 0,
            :exon_fill_color => :green_white_h,
            :utr_fill_color => :red_white_h,
            :gap_marker => 'angled',
          )
        end
        trna_track.add(obj)
      else
        unless other_track
          other_track = page.add_track(
            :glyph => :transcript,
            :name => 'other',
            :feature_height => 20,
            :line_width => 0,
            :exon_fill_color => :yellow_white_h,
            :utr_fill_color => :red_white_h,
            :gap_marker => 'angled',
          )
        end
        other_track.add(obj)
      end
    end

    # reserve diagram width
    range = page.add_track(
      :glyph => :generic,
      :label => false,
      :feature_height => 2,
      :stroke_width => 1,
      :stroke => 'white',
      :fill_color => 'white',
      :line_color => 'white',
    )
    
    #rf = (f - offset) / 1000
    #rt = (t + offset) / 1000

    feature = Bio::Graphics::MiniFeature.new(
      :start => f, # rf * 1000,
      :end   => t, # rt * 1000,
      :strand => '+',
    )
    
    range.add(feature)
    
    svg = page.get_markup
    genes.first[:svg] = svg

    genes
  end
end
