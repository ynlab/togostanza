class Api::Stanza::ResourcesController < ApplicationController
  def show(stanza_id, id)
    val = Stanza.find(stanza_id).new(params).resource(id)

    render json: {id => val}
  end
end
