class StanzaController < ApplicationController
  def show(id, stanza_params)
    render inline: StanzaBase.detect(id).new(stanza_params).render
  end
end
