class StanzaController < ApplicationController
  def show(id, stanza_params)
    render inline: Stanza.find(id).new(stanza_params).render
  end

  def help(stanza_id)
    render inline: Stanza.find(stanza_id).new.help, layout: true
  end
end
