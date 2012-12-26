# coding: utf-8

require 'spec_helper'
feature 'スタンザを表示する' do
  context 'General Summary スタンザ' do
    scenario "遺伝子 sll1615" do
      visit stanza_path('general_summary_stanza', gene_id: 'sll1615')

      expect(page).to have_text('tRNA modification GTPase TrmE')
      expect(page).to have_text('trmE')
      expect(page).to have_text('mnmE; thdF')
    end
  end

  context 'Transcript Attributes スタンザ' do
    scenario "遺伝子 sll1615" do
      visit stanza_path('transcript_attributes_stanza', gene_id: 'sll1615')

      expect(page).to have_text('1455753')
      expect(page).to have_text('1457123')
    end
  end
end
