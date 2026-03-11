class SitemapsController < ApplicationController
  def index
    @resorts = Resort.all
    respond_to do |format|
      format.xml
    end
  end
end
