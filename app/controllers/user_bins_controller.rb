class UserBinsController < ApplicationController

  def create

    user = User.find_by(id: params[:user_id])
    bin = Bin.find_by(id: params[:bin_id])

    # error handling if can't find user or bin

    new_user_bin = UserBin.new(user_id: params[:user_id], bin_id: params[:bin_id])

    if new_user_bin.save
      render status: :ok, json: new_user_bin
    else
      render status: :bad_request, json: { errors: user_bin.errors }
    end

  end

end
