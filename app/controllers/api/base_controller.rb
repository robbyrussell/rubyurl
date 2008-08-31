class Api::BaseController < ApplicationController


  protected
    def xml_error_response( msg )
      "<errors><error>#{msg}</error></errors>"
    end  
end