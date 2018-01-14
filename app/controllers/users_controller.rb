class UsersController < ApplicationController

  def index
    # request coming from profile page
    if params[:id] != nil
      @user = User.find_by(id: params[:id])

      # get total distance user has travelled
      total_distance_travelled = @user.total_distance_travelled

      json_response = {
        user: @user,
        total_dist: total_distance_travelled
      }

      render status: :ok, json: json_response
    else # request coming from signin
      @user = User.find_by(email: params[:email], password: params[:password])
      if @user
        # get total distance user has travelled
        total_distance_travelled = @user.total_distance_travelled

        #get all user_bins
        user_bins = UserBin.where(user_id: @user.id)
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

        # render status: :ok, json: user_bins_array

        json_response = {
          user: @user,
          total_dist: total_distance_travelled,
          user_bins: user_bins_array
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


  end

  def create
    # user sign up
    @user = User.new({
      email: params[:email],
      username: params[:username],
      password: params[:password]
    })

    if @user.save

      # get total distance user has travelled
      total_distance_travelled = @user.total_distance_travelled

      json_response = {
        user: @user,
        total_dist: total_distance_travelled
      }

      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: user.errors }
    end

  end
end
