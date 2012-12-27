class StanzaController < ApplicationController
  def show(id, gene_id)
    klass = id.classify.constantize
    render inline: klass.new.render(gene_id), layout: 'application'
  end
end
