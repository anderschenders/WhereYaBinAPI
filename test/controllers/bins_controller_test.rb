require "test_helper"

describe BinsController do
  describe "index" do
    it "should be a working route" do
      get bins_path
      must_respond_with :success
    end

    it "should return json" do

    end


  end
end
