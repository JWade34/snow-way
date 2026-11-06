class PowderReportSnapshotJob < ApplicationJob
  queue_as :default

  def perform
    PowderReport.snapshot!
  end
end
