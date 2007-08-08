class LinksController < ApplicationController

  def index  
    @link = Link.new
  end

  def create
    website_url = params.include?(:website_url) ? params[:website_url] : params[:link][:website_url]
    @link = Link.find_or_create_by_website_url( website_url )
    @link.ip_address = request.remote_ip if @link.new_record?
    
    if @link.save
      calculate_links # application controller, refactor soon
      render :action => :show
    else
      flash[:warning] = 'There was an issue trying to create your RubyURL.'
      redirect_to :action => :invalid
    end
  end

  def redirect
    @link = Link.find_by_token( params[:token] )

    unless @link.nil?
      @link.add_visit(request)
      redirect_to @link.website_url
    else
      redirect_to :action => 'invalid'
    end
  end
end
