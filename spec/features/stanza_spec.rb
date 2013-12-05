require 'spec_helper'

describe 'スタンザ一覧画面にアクセスすると' do
  before do
    visit '/stanza'
  end

  it '以下のスタンザ名が確認できること' do
    page.should have_text('protein_names')
    page.should have_text('organism_names')
  end
end

describe 'Protein Names スタンザ(tax_id: 1148, gene_id: slr1311)にアクセスすると' do
  before do
    visit '/stanza/protein_names?tax_id=1148&gene_id=slr1311'
  end

  it '以下の情報が確認できること' do
    page.should have_text('Photosystem Q(B) protein')
    page.should have_text('sll1867')
    page.should have_text('Synechocystis sp. (strain PCC 6803 / Kazusa)')
  end
end
