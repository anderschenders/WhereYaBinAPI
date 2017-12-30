require "test_helper"

describe User do

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
