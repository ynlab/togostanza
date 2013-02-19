class StanzaController < ApplicationController
  def index
  end

  def show(id)
    render inline: Stanza.find(id).new(params).render
  end

  def help(stanza_id)
    render inline: Stanza.find(stanza_id).new.help, layout: true
  end
end
