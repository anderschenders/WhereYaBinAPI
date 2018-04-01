require 'user_data'
require 'firebase_admin'

class UsersController < ApplicationController

  include UserData

  def auth
    new_auth = FirebaseAdmin::Auth.instance
    id_token = params[:token]
    result = new_auth.verify_id_token(id_token)

    # check if user is already registered
    uid = result[0]["user_id"];
    @user = User.find_by(uid: uid)
    if @user #user exists, return user details

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
      render status: :bad_request, json: { error: "Unable to find user, please sign up!" }
    end

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
      username: params[:username],
      uid: params[:uid]
      })

    if @user.save

      json_response = {
        user: @user,
        total_dist: 0,
        user_bins: []
      }

      render status: :ok, json: json_response

    else
      render status: :bad_request, json: { errors: @user.errors }
    end

    # @user = User.new({
    #   email: params[:email],
    #   username: params[:username],
    #   password: params[:password]
    # })
    #
    # if @user.save
    #   # get total distance user has travelled
    #   total_distance_travelled = @user.total_distance_travelled
    #
    #   #get all user_bins
    #   user_bins_array = get_user_bins(@user)
    #
    #   json_response = {
    #     user: @user,
    #     total_dist: total_distance_travelled,
    #     user_bins: user_bins_array
    #   }
    #
    #   render status: :ok, json: json_response
    # else
    #   render status: :bad_request, json: { errors: @user.errors }
    # end

  end
end
