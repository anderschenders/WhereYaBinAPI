class UserBinsController < ApplicationController

  def create

    user = User.find_by(id: params[:user_id])
    bin = Bin.find_by(id: params[:bin_id])

    # error handling if can't find user or can't find bin

    new_user_bin = UserBin.new(user_id: params[:user_id], bin_id: params[:bin_id])

    render status: :ok, json: new_user_bin
  end

end
