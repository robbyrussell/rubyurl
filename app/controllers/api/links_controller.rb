class Api::LinksController < Api::BaseController
  def create
    @link = Link.find_or_create_by_website_url( params[:link][:website_url] )
    @link.ip_address = request.remote_ip if @link.new_record?      

    if @link.save        
      respond_to do |format|
        format.xml { render :xml => @link.to_api_xml }
        format.json { render :json => @link.to_api_json }        
      end
    else
      respond_to do |format|
        format.xml { render :xml => xml_error_response( "Unable to generate a RubyURL for you" ) }
        format.json { render :json => "Unable to generate a RubyURL for you".to_json }
      end  
    end
  end
end

