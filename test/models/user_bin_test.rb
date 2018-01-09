require "test_helper"

describe UserBin do

  before do
    @user_bin = user_bins(:one)
  end

  describe "relations" do
    it "should have one user" do
      @user_bin.must_respond_to :user
      @user_bin.user.must_be_kind_of User
    end

    it "should have one bin" do
      @user_bin.must_respond_to :bin
      @user_bin.bin.must_be_kind_of Bin
    end
  end

  describe "validations" do

    it "should be valid" do
      @user_bin.must_be :valid?
    end

    it "should not be valid without an action" do
      @user_bin.action = nil
      @user_bin.wont_be :valid?
    end

    it "should not be valid without a user latitude" do
      @user_bin.user_lat = nil
      @user_bin.wont_be :valid?
    end

    it "should not be valid without a user longitude" do
      @user_bin.user_lng = nil
      @user_bin.wont_be :valid?
    end
  end

end
