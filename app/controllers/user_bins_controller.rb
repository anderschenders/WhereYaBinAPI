class UserBinsController < ApplicationController

  def index
    user_bins = UserBin.where(user_id: params[:user_id])

    render status: :ok, json: user_bins
  end

  def create

    user = User.find_by(id: params[:user_id])
    user.bin_count += 1
    user.save

    bin = Bin.find_by(id: params[:bin_id])
    # add count to bin? First gotta make a column

    # error handling if can't find user or bin

    new_user_bin = UserBin.new(user_id: params[:user_id], bin_id: params[:bin_id])

    json_response = { new_user_bin: new_user_bin, updated_user: user }

    if new_user_bin.save
      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: user_bin.errors }
    end

  end

end
