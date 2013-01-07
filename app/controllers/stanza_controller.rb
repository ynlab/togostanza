class StanzaController < ApplicationController
  def show(id)
    klass = id.classify.constantize
    render inline: klass.new.render(request.query_parameters), layout: 'application'
  end
end
