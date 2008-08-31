class Api::LinksController < Api::BaseController
  def create
    respond_to do |format|
      format.xml do
        @link = Link.find_or_create_by_website_url( params[:link][:website_url] )
        @link.ip_address = request.remote_ip if @link.new_record?      
        if @link.save
          render :xml => @link.to_api_xml
        else
          render :xml => xml_error_response( "Unable to generate a RubyURL for you" )
        end
      end
    end
  end
end

