class PowderReportSnapshotJob < ApplicationJob
  queue_as :default

  def perform
    PowderReport.snapshot!
    IndexNowJob.perform_later
  end
end
