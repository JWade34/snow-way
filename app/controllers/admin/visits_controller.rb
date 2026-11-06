class Admin::VisitsController < Admin::BaseController
  before_action :set_resort, only: [ :edit, :update ]

  # The checklist: every resort, ridden ones checked.
  def index
    @visits = ResortVisit.includes(:resort).to_a.sort_by { |v| v.resort.name }
    @ridden_ids = @visits.map(&:resort_id).to_set
    @groups = Resort.order(:name).group_by(&:region_name).sort_by { |name, rs| [ rs.first.north_american? ? 0 : 1, name ] }
  end

  def checklist
    ids = Array(params[:resort_ids]).map(&:to_i).to_set
    ids.each { |id| ResortVisit.find_or_create_by!(resort_id: id) }
    kept = 0
    ResortVisit.where.not(resort_id: ids.to_a).find_each do |v|
      v.written? ? kept += 1 : v.destroy
    end
    notice = "Saved: #{ResortVisit.count} resorts ridden."
    notice += " #{kept} unchecked resort#{"s" unless kept == 1} kept because you've written about them (clear the take to remove)." if kept.positive?
    redirect_to admin_visits_path, notice: notice
  end

  def edit
  end

  def update
    if @visit.update(visit_params)
      redirect_to admin_visits_path, notice: "#{@resort.name} saved#{" and published" if @visit.published? && @visit.written?}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_resort
    @resort = Resort.find_by!(slug: params[:slug])
    @visit = @resort.visit || @resort.build_visit
  end

  def visit_params
    params.expect(resort_visit: [ :take, :tips, :when_ridden, :rating, :published ])
  end
end
