class UsersController < ApplicationController

  def index

    user = User.find_by(email: params[:email], password: params[:password])
    if user
      render status: :ok, json: user
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
