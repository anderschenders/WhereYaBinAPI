require "test_helper"

describe Bin do

  describe "relations" do

    before do
      @test_bin = Bin.new
    end

    it "should have user_bins when user_bins are created" do
      @test_bin.must_respond_to :user_bins

      user = users(:ands)
      bin = bins(:bin2)

      user_bin = UserBin.create!(user: user, bin: bin)

      bin.user_bins << user_bin

      bin.user_bins.must_include user_bin
    end

    # TODO: test has_many bins through user_bins
  end


  describe "validations" do

    before do
      @bin = bins(:bin1)
    end

    it "should be valid" do
      @bin.must_be :valid?
    end

    it "should not be valid without a bin_type" do
      @bin.bin_type = nil
      @bin.wont_be :valid?
    end

    it "should not be valid without a latitude" do
      @bin.latitude = nil
      @bin.wont_be :valid?
    end

    it "should not be valid without a longitude" do
      @bin.longitude = nil
      @bin.wont_be :valid?
    end

    it "should not be valid without a location" do
      @bin.location = nil
      @bin.wont_be :valid?
    end

  end
end
