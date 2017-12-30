require "test_helper"

describe User do

  describe "relations" do

    before do
      @test_user = User.new
    end

    it "should have user_bins when user_bins are created" do
      @test_user.must_respond_to :user_bins

      user = users(:ands)
      bin = bins(:bin2)

      user_bin = UserBin.create!(user: user, bin: bin)

      user.user_bins << user_bin

      user.user_bins.must_include user_bin
    end

    # TODO: test has_many bins through user_bins
  end

  describe "validations" do

    before do
      @user = users(:anders)
    end

    it "should be valid" do
      @user.must_be :valid?
    end

    it "should not be valid without a username" do
      @user.username = nil
      @user.wont_be :valid?
    end

    it "should not be valid without an email" do
      @user.email = nil
      @user.wont_be :valid?
    end

    it "should not be valid without a password" do
      @user.password = nil
      @user.wont_be :valid?
    end

  end
end
