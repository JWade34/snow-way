class OgImagesController < ApplicationController
  def resort
    resort = Resort.includes(:snow_forecasts).find_by!(slug: params[:id])
    expires_in 6.hours, public: true
    send_data OgImage.new(ResortSummary.new(resort)).to_png, type: "image/png", disposition: "inline"
  end

  # Share card for a known non-resort page, e.g. /og/page.png?path=/getting-there/denver-to-vail
  def page
    png = OgCard.for_path(params[:path].to_s).to_png
    expires_in 12.hours, public: true
    send_data png, type: "image/png", disposition: "inline"
  end

  # Instagram graphics. /social/report.png is this week's snowiest resorts (live); add ?size=story for 1080x1920.
  def social
    format = SocialCard::FORMATS.key?(params[:size]&.to_sym) ? params[:size] : "post"
    expires_in 1.hour, public: true
    send_data SocialCard.new(params[:kind], format: format, tip: params[:slug]).to_png, type: "image/png", disposition: "inline",
      filename: "snowway-#{[params[:kind], params[:slug]].compact.join("-")}-#{format}.png"
  end
end
