class VariationStanza < TogoStanza::Stanza::Base
  property :variation do |uri|
    filter = uri.blank? ? '# not filtered' : "FILTER(?gene = <#{uri}>)"

    query("http://semantic.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX tga: <http://togo.annotation.jp/sw/>
      PREFIX obo: <http://purl.obolibrary.org/obo/>
      PREFIX alfred: <http://bioinformatics.med.yale.edu/owl/alfred.owl#>

      SELECT
        ?gene,
        ?gene_id,
        ?gene_product,
        ?gene_symbol,
        ?valiationid,
        ?locus,
        ?valiation_type,
        ?valiation_id,
        ?alleleid,
        REPLACE(STR(?alleleid), "http://bioinformatics.med.yale.edu/owl/alfred.owl#GenomicAllele", "") AS ?allele,
        ?location,
        ?seqid,
        ?ref_allele
      WHERE {
         ?s ?p ?gene.
         ?s ?pp ?o.
         ?s <http://insdc.org/owl/feature_locus_tag> ?gene_id.
         ?s <http://insdc.org/owl/feature_product> ?gene_product.
         #{filter}
         OPTIONAL {?s <http://insdc.org/owl/feature_gene> ?gene_symbol.}
         ?valiationid alfred:geneID ?gene.
         ?valiationid alfred:referenceGenomicLocationInAssembly ?locus.
         ?valiationid alfred:validationStatus ?valiation_type.
         ?valiationid alfred:id ?valiation_id.
         ?valiationid alfred:snpID ?ref_allele.
         ?valiationid alfred:genomicAllele ?alleleid.
         ?locus alfred:start ?location.
         ?locus alfred:chromosomeName ?seqid.
        FILTER REGEX(STR(?gene), "http://genome.microbedb.jp/cyanobase/Synechocystis/genes")
      }
    SPARQL
  end
end
