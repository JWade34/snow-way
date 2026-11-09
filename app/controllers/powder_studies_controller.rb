class PowderStudiesController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.csv { send_data PowderStudy.to_csv, filename: "snow-way-powder-day-odds.csv", type: "text/csv" }
    end
  end
end
