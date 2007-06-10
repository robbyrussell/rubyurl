require File.dirname(__FILE__) + '/../spec_helper'

describe Visit do
  before(:each) do
    @visit = Visit.new
  end

  it "should be valid" do
    @visit.should be_valid
  end
end
