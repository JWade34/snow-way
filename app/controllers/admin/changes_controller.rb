class Admin::ChangesController < Admin::BaseController
  def index
    @proposed = SiteChange.where(status: "proposed").recent_first
    @changes = SiteChange.where.not(status: "proposed").recent_first.limit(200)
  end

  def approve
    change = SiteChange.find(params[:id])
    change.go_live! if change.status == "proposed"
    redirect_to admin_changes_path, notice: "Approved: #{change.kind} on #{change.path} is live and being measured."
  end

  def revert
    change = SiteChange.find(params[:id])
    if change.status == "proposed"
      change.update!(status: "skipped", decided_at: Time.current, result: (change.result || {}).merge("note" => "declined by Justin"))
    elsif change.status.in?(%w[live kept])
      change.revert!(note: "reverted by Justin")
    end
    redirect_to admin_changes_path, notice: "Done: #{change.path} is back to how it was."
  end
end
