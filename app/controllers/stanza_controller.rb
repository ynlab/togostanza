class StanzaController < ApplicationController
  def show(id)
    klass = "#{id.camelize}Stanza".constantize

    render inline: klass.new(params).render, layout: id
  end
end
