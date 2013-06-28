require 'spec_helper'

describe Api::StanzaController do
  describe 'GET show' do
    before do
      get :show, id: 'protein_names_and_origin', tax_id: '1111708', gene_id: 'slr1311'
    end

    it { response.should be_success }

    it { response.body.should be_json_eql(<<-JSON.strip_heredoc) }
      {
        "css_uri": "/stanza/assets/stanza.css",
        "genes": [
          {
            "gene_name": "psbA2",
            "synonyms_name": "psbA-2",
            "locus_name": "slr1311"
          },
          {
            "gene_name": "psbA3",
            "synonyms_name": "psbA-3",
            "locus_name": "sll1867"
          }
        ],
        "summary": {
          "alternative_names": [
            "32 kDa thylakoid membrane protein 2",
            "Photosystem II protein D1 2"
          ],
          "ec_name": "1.10.3.9",
          "organism_name": "Synechocystis sp. (strain PCC 6803 / Kazusa)",
          "parent_taxonomy_names": [
            "cellular organisms",
            "Oscillatoriophycideae",
            "Cyanobacteria",
            "Synechocystis",
            "Chroococcales",
            "Bacteria",
            "Synechocystis sp. PCC 6803"
          ],
          "recommended_name": "Photosystem Q(B) protein 2",
          "taxonomy_id": "1111708"
        }
      }
    JSON
  end
end
