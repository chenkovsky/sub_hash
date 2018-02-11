require "./spec_helper"

describe SubHash do
  # TODO: Write tests

  it "works" do
    hasher = SubHash.new
    hasher.sub_hash "substrings"
    hasher[0, 10].should eq(SubHash.hash "substrings")
    hasher[3, 6].should eq(SubHash.hash "string")
    hasher[3, 3].should eq(SubHash.hash "str")
  end
end
