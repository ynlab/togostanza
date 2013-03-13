class VariationStanza < Stanza::Base
    property :title do
        'Variation'
    end

    property :variation do |uri|
        uri ||= ''
        filter = uri.empty? ? "#" : "FILTER( ?gene = <#{uri}>)"
query("http://semantic.annotation.jp/sparql", <<-SPARQL.strip_heredoc)
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tga: <http://togo.annotation.jp/sw/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX alfred: <http://bioinformatics.med.yale.edu/owl/alfred.owl#>
SELECT 
#?gene_id, ?gene_product, (sql:GROUP_CONCAT(?valiation_id, ", ")) as ?valiation_ids, count(?valiation_id) as ?valiation_count
#?gene_id, ?valiation_id
#?gene, ?gene_id, ?gene_product,?gene_symbol,?reference_count, ?annotation_uri,replace(str(?annotation_uri),"http://togo.annotation.jp/annotations/","")as ?annotation_id, ?annotation_count, ?curated_gene_symbol, ?valiationid, ?locus, ?valiation_type, ?valiation_id, ?alleleid,replace(str(?alleleid),"http://bioinformatics.med.yale.edu/owl/alfred.owl#GenomicAllele","")as ?allele, ?location, ?seqid
?gene, ?gene_id, ?gene_product,?gene_symbol, ?valiationid, ?locus, ?valiation_type, ?valiation_id, ?alleleid,replace(str(?alleleid),"http://bioinformatics.med.yale.edu/owl/alfred.owl#GenomicAllele","")as ?allele, ?location, ?seqid, ?ref_allele
WHERE 
{
#?gene <http://purl.org/kazusa/genome/genbank#locus_tag> ?gene_id.
#?gene <http://purl.org/kazusa/genome#product> ?gene_product.
?gene <http://genome.microbedb.jp/terms/genbank#locus_tag> ?gene_id.
?gene <http://genome.microbedb.jp/terms/genome#product> ?gene_product.
#{filter}
#OPTIONAL {?gene <http://purl.org/kazusa/genome/genbank#gene> ?gene_symbol.}
OPTIONAL {?gene <http://genome.microbedb.jp/terms/genbank#gene> ?gene_symbol.}
#?gene tga:reference_count ?reference_count.
#?gene tga:annotation_id ?annotation_uri.
#?gene tga:annotation_count ?annotation_count.
#?gene rdfs:label ?curated_gene_symbol.
#?gene rdf:type obo:SO_0000704.
?valiationid alfred:geneID ?gene.
?valiationid alfred:referenceGenomicLocationInAssembly ?locus.
?valiationid alfred:validationStatus ?valiation_type.
?valiationid alfred:id ?valiation_id.
?valiationid alfred:snpID ?ref_allele.
?valiationid alfred:genomicAllele ?alleleid.
?locus alfred:start ?location.
?locus alfred:chromosomeName ?seqid.
FILTER regex(str(?gene),"http://genome.microbedb.jp/cyanobase/Synechocystis/genes")
#FILTER (?gene_id != ?curated_gene_symbol)

} 
#GROUP BY ?gene_id ?gene_product ORDER BY DESC(count(?valiation_id))
#LIMIT 100

SPARQL
    end
end
