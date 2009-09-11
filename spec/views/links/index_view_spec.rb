require File.dirname(__FILE__) + '/../../spec_helper'

describe "links/index" do
  before(:each) do
    render 'links/index'
  end

  it "should display Create a RubyURL in a h1 tag" do
    response.should have_tag('label', 'Create a RubyURL')
  end

  it "should display a text input field for the user to paste their url in" do
    response.should have_tag('input#link_website_url')
  end
end

describe "links/show" do

  before(:each) do
    @link = mock_model(Link)
    @link.stub!(:permalink).and_return('http://localhost:3000/x093')
    @link.stub!(:website_url).and_return('http://rubyurl.com/')
    assigns[:link] = @link
    render 'links/show'
  end

  it "should display Here is your RubyURL in a h1 tag" do
    response.should have_tag('dt', 'Here is your RubyURL')
  end

  it "should display a link for the user to copy" do
    response.should have_tag('div#url')
    response.should have_tag('a', 'http://localhost:3000/x093')
  end

  it "should display the correct number of characters for the original URL (16)" do
    response.should have_tag('dd', '19 characters')
  end
end