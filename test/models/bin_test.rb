require "test_helper"

describe Bin do

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

  end
end
