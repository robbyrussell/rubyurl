require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController do
  include LinkSpecHelper

  controller_name :links
  
  it "should not save a new link wihout a website url" do
    post :new, :link => valid_attributes.except(:website_url)
    assigns(:link).should have_at_least(1).errors_on(:website_url)
  end
  
  it "should save a new link with valid attributes" do
    lambda do
      post :new, :link => valid_attributes
    end.should change(Link, :count).by(1)
  end
end
