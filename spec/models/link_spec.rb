require File.dirname(__FILE__) + '/../spec_helper'

describe Link, "with fixtures loaded" do
  fixtures :links
  
  it "should load a non-empty collection of links" do
    Link.find(:all).should_not be_empty
  end
  
  it "should have four records" do
    Link.should have(4).records
  end
end

describe "Planet Argon link " do
  fixtures :links, :visits
  
  before(:each) do
    @link = Link.find(links(:planetargon).id)
  end
  
  it "should have a matching website url" do
    @link.website_url.should eql(links(:planetargon).website_url)
  end
  
  it "should have two (2) visits" do
    @link.should have(2).visits
  end
  
  it "should not be flagged as spam" do
    @link.flagged_as_spam?.should be_false
  end
  
  it "should add a new visit with .add_visit" do
    request = mock('request')
    request.stub!(:remote_ip).and_return('127.0.0.1')
    lambda do
      @link.add_visit(request)
    end.should change(@link.visits, :count).by(1)
  end
end

describe "Spammer site" do
  fixtures :links, :visits
  
  before(:each) do 
    @link = Link.find(links(:spammer_site).id)
  end
  
  it "should have one (1) visits" do
    @link.should have(1).visits
  end
  
  it "should have one flagged as spam visit" do
    @link.should have(1).spam_visits
  end
  
  it "should be flagged as spam" do
    @link.flagged_as_spam?.should be_true    
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
  
  it "should generate a token when saved" do
    @link.attributes = valid_attributes
    @link.token.should be_nil
    @link.save.should be_true
    @link.token.should_not be_nil
  end
  
  it "should generate a permalink when created" do
    @link.attributes = valid_attributes
    @link.permalink.should be_nil
    @link.save.should be_true
    @link.permalink.should_not be_nil
    @link.permalink.should eql(DOMAIN_NAME + @link.token)
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

describe "A new link" do
  include LinkSpecHelper    
  
  it "should not save when provided a URL without http://" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'google.com'
    @link.should have(1).error_on(:website_url)
  end
  
  it "should save a link without a .com/.net/.org/etc." do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://hamster-style/'
    @link.should have(0).errors_on(:website_url)
  end

  it "should save a link with query string parameters" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://hamsterstyle.com/foo?x=1'
    @link.should have(0).errors_on(:website_url)
  end    

  it "should save a link with an achor tag and retain it" do
    @link = Link.new
    @link.attributes = valid_attributes.except(:website_url)
    @link.website_url = 'http://hamsterstyle.com/foo?x=1#test'
    @link.save
    @link.website_url.should == 'http://hamsterstyle.com/foo?x=1#test'
  end
end

