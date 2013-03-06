# coding: utf-8

require 'spec_helper'

feature 'スタンザを表示する' do
  context 'General Summary スタンザ' do
    scenario '遺伝子 sll1615' do
      visit stanza_path('general_summary', gene_id: 'sll1615')

      expect(page).to have_text('tRNA modification GTPase TrmE')
      expect(page).to have_text('trmE')
      expect(page).to have_text('mnmE; thdF')
    end
  end

  context 'Transcript Attributes スタンザ' do
    scenario '遺伝子 sll1615' do
      visit stanza_path('transcript_attributes', gene_id: 'sll1615')

      expect(page).to have_text('1455753')
      expect(page).to have_text('1457123')
    end
  end

  context 'Gene Attributes スタンザ' do
    scenario '遺伝子 slr1311 / taxid: 1148' do
      visit stanza_path('gene_attributes', gene_id: 'slr1311', tax_id: '1148')

      expect(page).to have_text('photosystem II D1 protein')
      expect(page).to have_text('psbA2')
      expect(page).to have_text('MTTTLQQRESASLWEQFCQWVTSTNNRIYVGWFGTLMIPTLLTATTCFIIAFIAAPPVDIDGIREPVAGSLLYGNNIISGAVVPSSNAIGLHFYPIWEAASLDEWLYNGGPYQLVVFHFLIGIFCYMGRQWELSYRLGMRPWICVAYSAPVSAATAVFLIYPIGQGSFSDGMPLGISGTFNFMIVFQAEHNILMHPFHMLGVAGVFGGSLFSAMHGSLVTSSLVRETTEVESQNYGYKFGQEEETYNIVAAHGYFGRLIFQYASFNNSRSLHFFLGAWPVIGIWFTAMGVSTMAFNLNGFNFNQSILDSQGRVIGTWADVLNRANIGFEVMHERNAHNFPLDLASGEQAPVALTAPAVNG
')
      expect(page).to have_text('7229..8311')
      expect(page).to have_text('http://purl.uniprot.org/refseq/NP_439906.1')
    end
  end
end

feature '表示のカスタマイズ' do
  scenario 'デフォルトでは Bootstrap が使われる' do
    visit stanza_path('general_summary', gene_id: 'sll1615')

    expect(find('link[rel=stylesheet]')[:href]).to match(%r(/bootstrap.min.css$))
  end

  scenario 'css_uri を指定すると、代わりにそれが使われる' do
    visit stanza_path('general_summary', gene_id: 'sll1615', css_uri: 'http://example.com/my.css')

    expect(find('link[rel=stylesheet]')[:href]).to eq('http://example.com/my.css')
  end
end
