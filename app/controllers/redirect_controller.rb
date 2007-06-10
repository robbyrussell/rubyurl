class RedirectController < ApplicationController
  layout 'redirect'

  def index
    @link = Link.find_by_token( params[:token] )
    @link.add_visitor(request)
    redirect_to :controller => 'go' if @link.nil?
  end
  
  def top
    render :layout => false
  end
  
  def flagged
    render :layout => false
  end
end



