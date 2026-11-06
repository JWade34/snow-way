class PowderReportsController < ApplicationController
  def current
    @data = PowderReport.build_data
    @archive = PowderReport.order(week_of: :desc).limit(12)
    render :show
  end

  def show
    report = PowderReport.find_by!(week_of: params[:id])
    @data = report.data
    @archive = PowderReport.where.not(id: report.id).order(week_of: :desc).limit(12)
    @archived = true
  end
end
