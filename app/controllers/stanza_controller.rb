class StanzaController < ApplicationController
  def show(id, stanza_params)
    klass = "#{id.camelize}Stanza".constantize

    render inline: klass.new(stanza_params).render, layout: id
  end
end
