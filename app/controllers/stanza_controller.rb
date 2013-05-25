class StanzaController < ApplicationController
  def index
  end

  def show(id)
    render text: Stanza.find(id).new(params).render, content_type: 'text/html'
  end

  def help(stanza_id)
    render text: Stanza.find(stanza_id).new.help, layout: true, content_type: 'text/html'
  end
end
