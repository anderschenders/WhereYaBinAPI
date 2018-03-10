require 'user_data'
require 'firebase_admin'

class UsersController < ApplicationController

  include UserData

  def auth
    new_auth = FirebaseAdmin::Auth.instance
    id_token = params[:token]
    result = new_auth.verify_id_token(id_token)

    puts result

    # check if user is already registered
    uid = result[0]["user_id"];
    puts uid
    @user = User.find_by(uid: uid)

    

    json_response = {
      result: result,
    }

    render status: :ok, json: json_response
  end

  def index
    @user = User.find_by(email: params[:email], password: params[:password])
    # @user = User.find_by(token: params[:token])
    if @user

      user_stats = user_stats(@user)

      json_response = {
        user: @user,
        total_dist: user_stats[:total_distance_travelled],
        user_bins: user_stats[:user_bins_formatted],
        use_total: user_stats[:user_bins_use_total],
        total_rec: user_stats[:user_bins_total_rec],
        total_gar: user_stats[:user_bins_total_gar],
        total_reports: user_stats[:user_bins_total_reports],
        full_reports: user_stats[:user_bins_full_reports],
        missing_reports: user_stats[:user_bins_missing_reports],
        add_reports: user_stats[:user_bins_add_reports]
      }

      render status: :ok, json: json_response
    else
      user = User.find_by(email: params[:email])
      if user.nil?
        render status: :bad_request, json: { error: 'Invalid email. Please try again.' }
      else
        render status: :bad_request, json: { error: 'Invalid password. Please try again.' }
      end
    end

  end

  def create
    # new user sign up
    @user = User.new({
      email: params[:email],
      username: params[:username],
      password: params[:password]
    })

    if @user.save
      # get total distance user has travelled
      total_distance_travelled = @user.total_distance_travelled

      #get all user_bins
      user_bins_array = get_user_bins(@user)

      json_response = {
        user: @user,
        total_dist: total_distance_travelled,
        user_bins: user_bins_array
      }

      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: @user.errors }
    end

  end
end

# private
#
# def get_user_bins(user)
#   user_bins = UserBin.where(user_id: user.id)
#   user_bins_sorted = user_bins.order(:created_at).reverse
#
#
#   user_bins_formatted = []
#   user_bins_sorted.each do |user_bin|
#     bin = Bin.find_by(id: user_bin.bin_id)
#     user_bin_attributes = user_bin.attributes
#     user_bin_attributes["bin_type"] = bin.bin_type
#     user_bins_formatted << user_bin_attributes
#   end
#
#   return user_bins_formatted
# end
