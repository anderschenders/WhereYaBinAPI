require "test_helper"

describe UsersController do
  describe "index" do
    it "should respond with success when given valid data" do
      params = {
        email: "anders@chenders.com",
        password: "meow"
      }

      get users_path, params: params
      must_respond_with :success
      response.header['Content-Type'].must_include 'json'
    end

    it "should respond with bad_request when given invalid data" do
      params = {
        email: "invalid@email.com",
        password: "meow"
      }

      get users_path, params: params
      must_respond_with :bad_request
    end
  end

  describe "create" do
    it "should respond with success when given valid data" do
      params = {
        username: "newuser",
        email: "new@user.com",
        password: "new"
      }

      post users_path, params: params
      must_respond_with :success
      response.header['Content-Type'].must_include 'json'
    end

    it "should respond with bad_request when given invalid data" do
      params = {
        username: "newuser2",
        password: "meow"
      }

      post users_path, params: params
      must_respond_with :bad_request
    end
  end
end
