class StanzaController < ApplicationController
  def show(id, stanza_params)
    render inline: find_stanza(id).new(stanza_params).render
  end

  def help(stanza_id)
    render inline: find_stanza(stanza_id).new.render_help, layout: true
  end

  private

  def find_stanza(slug)
    StanzaBase.find_by_slug(slug)
  end
end
