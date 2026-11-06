# A weekly, dated snapshot of the snow rankings. The current week is computed live;
# past weeks are frozen here so their archive pages never change after publication.
class PowderReport < ApplicationRecord
  validates :week_of, presence: true, uniqueness: true

  def self.build_data(as_of = Date.current)
    totals = Resort.projected_totals(as_of)
    recent = Resort.recent_totals(as_of)
    resorts = Resort.north_america.to_a
    ranked = resorts.sort_by { |r| -totals.fetch(r.id, 0.0) }
    row = ->(r, value) { { "slug" => r.slug, "name" => r.name, "region" => r.state_province, "inches" => value } }
    avg = ->(list) { list.any? ? (list.sum { |r| totals.fetch(r.id, 0.0) } / list.size).round(1) : 0.0 }

    {
      "as_of" => as_of.iso8601,
      "window" => [ as_of.iso8601, (as_of + 6).iso8601 ],
      "tracked" => resorts.size,
      "snowing_count" => resorts.count { |r| totals.fetch(r.id, 0.0) > 0 },
      "top" => ranked.first(10).map { |r| row.(r, totals.fetch(r.id, 0.0)) },
      "fresh" => resorts.select { |r| recent.fetch(r.id, 0.0) > 0 }.sort_by { |r| -recent[r.id] }.first(5).map { |r| row.(r, recent[r.id]) },
      "regions" => resorts.group_by(&:state_province).map { |region, rs| [ region, rs.max_by { |r| totals.fetch(r.id, 0.0) } ] }
        .select { |_, r| totals.fetch(r.id, 0.0) > 0 }.sort_by { |_, r| -totals.fetch(r.id, 0.0) }.first(8).map { |region, r| row.(r, totals[r.id]) },
      "epic_avg" => avg.(resorts.select(&:on_epic?)),
      "ikon_avg" => avg.(resorts.select(&:on_ikon?))
    }
  end

  def self.snapshot!(as_of = Date.current)
    find_or_initialize_by(week_of: as_of).tap { |report| report.update!(data: build_data(as_of)) }
  end

  def to_param
    week_of.iso8601
  end
end
