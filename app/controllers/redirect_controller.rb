class RedirectController < ApplicationController
  layout 'redirect'

  def index
    @link = Link.find_by_token( params[:token] )

    unless @link.nil?
      @link.add_visit(request)
      redirect_to @link.website_url
    else
      redirect_to :controller => 'links', :action => 'invalid'
    end
  end
  
  def top
    render :layout => false
  end
  
  def flagged
    render :layout => false
  end
end



