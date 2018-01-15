require "test_helper"

describe UserBinsController do
  describe "create" do
    it "should respond with success when given valid data" do
      user = users(:anders)
      user_id = user.id

      bin = bins(:bin1)
      bin_id = bin.id

      params = {
        user_id: user_id,
        bin_id: bin_id,
        user_action: "use",
        user_lat: 24.25,
        user_lng: -122.45
      }

      post user_bins_path, params: params
      must_respond_with :success
      response.header['Content-Type'].must_include 'json'
    end

    it "should respond with bad_request when given invalid data" do
      user = users(:anders)
      user_id = user.id

      bin = bins(:bin1)
      bin_id = bin.id

      params = {
        user_id: user_id,
        bin_id: bin_id,
        user_action: "use",
        user_lat: 24.25,
        # user_lng: -122.45
      }

      post user_bins_path, params: params
      must_respond_with :bad_request
    end
  end

  describe "community_data" do
    it "should be a working route " do
      get community_data_path
      must_respond_with :success
    end

    it "should respond with JSON" do
      get community_data_path
      response.header['Content-Type'].must_include 'json'
    end
  end
end
