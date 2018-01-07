class UserBinsController < ApplicationController

  def index
    user_bins = UserBin.where(user_id: params[:user_id])
    user_bins_sorted = user_bins.order(:created_at).reverse

    user_bins_array = user_bins_sorted.each_slice(1).to_a

    user_bins_array.each do |user_bin|
      bin = Bin.find_by(id: user_bin[0].bin_id)
      if bin.bin_type === "RYPUBL"
        user_bin << { "bin_type" => "RECYCLING" }
      else
        user_bin << { "bin_type" => "GARBAGE" }
      end
    end

    # get bin type of each userbin and add to response
    # user_bins.each do |user_bin|
    #   bin = Bin.find_by(id: user_bin.bin_id)
    #   if bin.bin_type === "RYPUBL"
    #     user_bin["bin_type"] = "RECYCLING"
    #   else
    #     user_bin["bin_type"] = "GARBAGE"
    #   end
    # end

    render status: :ok, json: user_bins_array
  end

  def create

    user = User.find_by(id: params[:user_id])
    user.bin_count += 1
    user.save

    bin = Bin.find_by(id: params[:bin_id])
    # add count to bin? First gotta make a column

    # error handling if can't find user or bin

    new_user_bin = UserBin.new(user_id: params[:user_id], bin_id: params[:bin_id], action: params[:userAction])

    json_response = { new_user_bin: new_user_bin, updated_user: user }

    if new_user_bin.save
      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: user_bin.errors }
    end

  end

end
