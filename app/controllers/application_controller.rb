class ApplicationController < ActionController::Base
  before_action :redirect_www


  private

  def redirect_www
    if request.host == "www.snowway.app"
      redirect_to "https://snowway.app#{request.fullpath}", status: :moved_permanently, allow_other_host: true
    end
  end
end
