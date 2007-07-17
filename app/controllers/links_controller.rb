class LinksController < ApplicationController

  def new
    @link = Link.find_or_create_by_website_url( params[:link][:website_url] )
    @link.ip_address = request.remote_ip if @link.new_record?
    
    if @link.save
      calculate_links # application controller
      render :action => :show
    else
      flash[:warning] = 'There was an issue trying to create your RubyURL.'
    end
  end
  
  def invalid
    
  end

  def redirect
    @link = Link.find_by_token( params[:token] )

    unless @link.nil?
      @link.add_visit(request)
      redirect_to @link.website_url
    else
      redirect_to :controller => 'links', :action => 'invalid'
    end
  end
end
