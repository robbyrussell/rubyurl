require File.dirname(__FILE__) + '/../spec_helper'

module LinkSpecHelper
  def valid_attributes
    {:website_url => 'http://www.google.com/', :ip_address => '192.168.1.1'}
  end
end

describe Link, "with fixtures loaded" do
  fixtures :links
  
  it "should load a non-empty collection of links" do
    Link.find(:all).should_not be_empty
  end
  
  it "should have three records" do
    Link.should have(3).records
  end
end

describe "Planet Argon link " do
  fixtures :links
  
  before(:each) do
    @link = Link.find(links(:planetargon).id)
  end
  
  it "should have a matching website url" do
    @link.website_url.should eql(links(:planetargon).website_url)
  end
end

describe Link, "a new link" do
  include LinkSpecHelper
  
  before(:each) do
    @link = Link.new
  end
  
  it "should be invalid without a website url" do
    @link.attributes = valid_attributes.except(:website_url)
    @link.should have(1).error_on(:website_url)
  end
  
  it "should be invalid without an ip address" do
    @link.attributes = valid_attributes.except(:ip_address)
    @link.should have(1).error_on(:ip_address)    
  end
  
  it "should be valid with valid attributes" do
    @link.attributes = valid_attributes
    @link.should be_valid
  end
  
  it "should generate a token upon save" do
    @link.attributes = valid_attributes
    @link.token.should be_nil
    @link.save.should be_true
    @link.token.should_not be_nil
  end
end

describe "A new Link, which already exists" do
  include LinkSpecHelper
  
  before(:each) do
    @link = Link.new
    @link.attributes = valid_attributes
    @link.save
  end
  
  it "should return the original link rather than create a new one" do
    new_link = Link.find_or_create_by_website_url(valid_attributes[:website_url])
    new_link.should eql(@link)
  end
end
