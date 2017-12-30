require "test_helper"

describe UserBin do
  let(:user_bin) { UserBin.new }

  it "must be valid" do
    value(user_bin).must_be :valid?
  end
end
