class LeadMagnetsController < ApplicationController
  MAGNETS = {
    "powder-calendar" => { label: "Powder Calendar", pdf: -> { PowderCalendarPdf.new.render }, filename: -> { "snow-way-powder-calendar-#{PowderCalendarPdf.season_label}.pdf" } },
    "packing-checklist" => { label: "Ski Trip Packing Checklist", pdf: -> { PackingChecklistPdf.new.render }, filename: -> { "snow-way-ski-trip-packing-checklist.pdf" } },
    "ski-trip-planner" => { label: "Ski Trip Planner", pdf: -> { TripPlannerPdf.new.render }, filename: -> { "snow-way-ski-trip-planner.pdf" } }
  }.freeze

  def powder_calendar
    @resorts = Resort.order(:name).to_a
    @regions = @resorts.group_by(&:state_province)
  end

  def ski_trip_planner
    @hubs = SkiHub.all.sort_by { |hub| -hub.nearby.count { |_, mi| mi <= 120 } }.first(5)
  end

  def download
    Subscriber.find_by!(token: params[:token])
    magnet = MAGNETS.fetch(params[:magnet] || "powder-calendar") { raise ActiveRecord::RecordNotFound }
    pdf = Rails.cache.fetch("lead-magnet/#{params[:magnet]}/#{Date.current}/#{Resort.maximum(:updated_at)&.to_i}", expires_in: 1.day) { magnet[:pdf].call }
    response.headers["X-Robots-Tag"] = "noindex"
    send_data pdf, filename: magnet[:filename].call, type: "application/pdf", disposition: "attachment"
  end
end
