require "test_helper"

describe Bin do
  let(:bin) { Bin.new }

  it "must be valid" do
    value(bin).must_be :valid?
  end
end
