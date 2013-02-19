class Api::StanzaController < ApplicationController
  def show(id)
    render json: Stanza.find(id).new(params).context
  end
end
