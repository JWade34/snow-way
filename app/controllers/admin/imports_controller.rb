class Admin::ImportsController < Admin::BaseController
  def new
  end

  def create
    @text = params[:text].to_s
    @import = ResortVisitImport.new(@text).run!
    render :new
  end
end
