class OgImagesController < ApplicationController
  def resort
    resort = Resort.includes(:snow_forecasts).find_by!(slug: params[:id])
    expires_in 6.hours, public: true
    send_data OgImage.new(ResortSummary.new(resort)).to_png, type: "image/png", disposition: "inline"
  end
end
