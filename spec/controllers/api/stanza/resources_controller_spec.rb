require 'spec_helper'

describe Api::Stanza::ResourcesController do
  describe 'GET show' do
    let :stanza do
      Class.new(Stanza::Base) {
        resource :greeting do |name|
          "hello, #{name}!"
        end
      }
    end

    before do
      Stanza.stub(:find) { stanza }

      get :show, stanza_id: 'a_stanza', id: 'greeting', name: 'ursm'
    end

    it { response.should be_success }

    it { response.body.should be_json_eql(<<-JSON.strip_heredoc) }
      {"greeting": "hello, ursm!"}
    JSON
  end
end
