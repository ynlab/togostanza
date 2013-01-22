class StanzaController < ApplicationController
  def show(id, stanza_params)
    render inline: StanzaBase.find_by_slug(id).new(stanza_params).render
  end
end
