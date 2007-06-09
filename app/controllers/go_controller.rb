class GoController < ApplicationController
  def index  
    @link = Link.new
  end
end
