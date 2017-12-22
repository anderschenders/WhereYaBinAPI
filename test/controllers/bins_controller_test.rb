require "test_helper"

describe BinsController do
  describe "index" do
    it "should be a working route" do
      get bins_path
      must_respond_with :success
    end

    it "should return json" do
      get bins_path
      response.header['Content-Type'].must_include 'json'
    end

    it "should return an Array" do
      get bins_path

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "should return bins with all the attributes " do
      keys = %w(bin_type created_at created_by id latitude longitude updated_at)

      get bins_path
      body = JSON.parse(response.body)
      body.each do |bin|
        bin.keys.sort.must_equal keys
      end
    end

  end
end
