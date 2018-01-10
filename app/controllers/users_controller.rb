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

        json_response = {
          user: @user,
          total_dist: total_distance_travelled
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
    user = User.create({
      email: params[:email],
      username: params[:username],
      password: params[:password]
    })

    if user.save
      render status: :ok, json: user
    else
      render status: :bad_request, json: { errors: user.errors }
    end

  end
end
