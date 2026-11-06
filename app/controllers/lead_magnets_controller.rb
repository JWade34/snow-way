class LeadMagnetsController < ApplicationController
  def powder_calendar
    @resorts = Resort.order(:name).to_a
    @regions = @resorts.group_by(&:state_province)
  end

  def download
    Subscriber.find_by!(token: params[:token])
    pdf = Rails.cache.fetch("powder-calendar-pdf/#{Date.current}/#{Resort.maximum(:updated_at)&.to_i}", expires_in: 1.day) { PowderCalendarPdf.new.render }
    response.headers["X-Robots-Tag"] = "noindex"
    send_data pdf, filename: "snow-way-powder-calendar-#{PowderCalendarPdf.season_label}.pdf", type: "application/pdf", disposition: "attachment"
  end
end
