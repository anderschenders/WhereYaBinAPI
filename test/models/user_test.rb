require "test_helper"

describe User do

  before do
    @test_user = User.new(username: 'test', email: 'test@test.com', password: 'test')
  end

  describe "relations" do

    # TODO: this test is now erroring?
    it "should have user_bins when user_bins are created" do
      @test_user.must_respond_to :user_bins

      user = users(:ands)
      bin = bins(:bin2)

      user_bin = UserBin.create!(user: user, bin: bin, action: 'use', user_lat: 12.12, user_lng: 122.12)

      user.reload
      # user.user_bins << user_bin

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

    # BUG: below test failing
    it "should be initiated with bin_count 0" do
      @test_user.save
      # @test_user.reload
      @test_user.bin_count.must_equal 0
    end

  end

  describe "custom methods" do

    before do
      @user = users(:anders)
    end

    describe "total_distance_travelled" do

      it "should return 0 if user has no bins" do
        user = users(:ands)
        user.total_distance_travelled.must_equal 0
      end

      it "should return a Float" do
        puts @user.total_distance_travelled
        @user.total_distance_travelled.must_be_kind_of Float
      end

    end
  end
end
