require 'spec_helper'

describe Api::StanzaController do
  describe 'GET show' do
    before do
      get :show, id: 'transcript_attributes', gene_id: 'slr0613'
    end

    it { response.should be_success }

    it { response.body.should be_json_eql(<<-JSON.strip_heredoc) }
      {
        "css_uri": "//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.2.2/css/bootstrap.min.css",
        "title": "Transcript Attributes : slr0613",

        "transcripts": [
          {"end_position": "2098", "begin_position": "1577"}
        ]
      }
    JSON
  end
end
