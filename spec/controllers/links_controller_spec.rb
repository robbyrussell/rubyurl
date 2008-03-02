require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController, "index action" do
  controller_name :links
  
  it "should redirect to the home action" do
    get :index
    response.should redirect_to( :action => 'home' )
  end
end

describe LinksController, "home action" do
  controller_name :links
  
  before(:each) do
    @link = mock('link')
    Link.stub!(:new).and_return(@link)    
    get :home
  end
  
  it "should render the index view" do
    response.should render_template('links/index')
  end

  it "should instantiate a new link variable" do
    assigns[:link].should equal(@link)
  end  
end

describe LinksController do
  include LinkSpecHelper

  controller_name :links
  
  it "should not save a new link wihout a website url" do
    post :create, :link => valid_attributes.except(:website_url)
    assigns(:link).should have_at_least(1).errors_on(:website_url)
  end
  
  it "should save a new link with valid attributes" do
    lambda do
      post :create, :link => valid_attributes
    end.should change(Link, :count).by(1)
  end
end

describe LinksController, "redirect routing" do
  controller_name :links
  
  it "should route to the redirect action in LinksController" do
    assert_routing '/abc', { :controller => 'links', :action => 'redirect', :token => 'abc' }
  end
  
  it "should redirect to the invalid page when the token is invalid" do
    get :redirect, :token => 'magoo'
    response.should redirect_to( :action => 'invalid' )
  end
end

describe LinksController, "redirect with token" do
  
  before(:each) do
    @link = mock( 'link' )
    Link.should_receive( :find_by_token ).with( 'abc' ).and_return( @link )
    @link.stub!( :add_visit )
    @link.should_receive( :website_url ).and_return( 'http://google.com/' )
    get :redirect, :token => 'abc'    
  end
  
  it "should call redirected to a website when passed a token" do
    response.should redirect_to( 'http://google.com/' )
  end
end

