class UsersController < ApplicationController

  def index

    user = User.find_by(email: params[:email], password: params[:password])
    if user
      render status: :ok, json: user
    else
      render status: :bad_request, json: { errors: errors }
    end

  end

  def create

    user = User.create({
      email: params[:email],
      username: params[:username],
      password: params[:password]
    })

    render status: :ok, json: user


    # else create an account and log them in
    # send back message and user data
  end

end
