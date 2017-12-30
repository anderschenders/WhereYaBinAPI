class BinsController < ApplicationController

  def index
    data = Bin.all

    render status: :ok, json: data
  end

end
