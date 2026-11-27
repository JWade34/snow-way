# Small read-only JSON feed for the Snow Way iPhone app's native features (Siri, Shortcuts, Spotlight).
# Public forecast data only, the same numbers every resort page shows. Cached for 15 minutes.
module Api
  class AppController < ApplicationController
    before_action { expires_in 15.minutes, public: true }

    # Top resorts by forecast snow: the answer to "Hey Siri, where's the powder?"
    def powder
      week = Resort.projected_totals(days: 7)
      three = Resort.projected_totals(days: 3)
      resorts = Resort.where(id: week.keys).index_by(&:id)
      top = week.sort_by { |_, v| -v }.filter_map { |id, _| resorts[id] }.first(params.fetch(:limit, 5).to_i.clamp(1, 20))
      render json: { updated_at: SnowForecast.maximum(:updated_at), resorts: top.map { |r| card(r, week, three) } }
    end

    # Resort search for Siri's resort picker. With no query, the snowiest resorts come first.
    def resorts
      q = params[:q].to_s.strip
      scope = q.present? ? Resort.where("name LIKE ?", "%#{Resort.sanitize_sql_like(q)}%").order(:name) : Resort.order(:name)
      scope = scope.where(slug: params[:slugs].to_s.split(",")) if params[:slugs].present?
      week = Resort.projected_totals(days: 7)
      list = scope.limit(500).to_a
      list = list.sort_by { |r| -week[r.id].to_f } if q.blank?
      render json: { resorts: list.first(q.present? ? 25 : 50).map { |r| { slug: r.slug, name: r.name, region: region(r) } } }
    end

    def resort
      r = Resort.find_by!(slug: params[:slug])
      render json: card(r, Resort.projected_totals(days: 7), Resort.projected_totals(days: 3))
    end

    private

    def card(r, week, three)
      { slug: r.slug, name: r.name, region: region(r), next_3_days_in: three[r.id].to_f.round, next_7_days_in: week[r.id].to_f.round,
        temp_f: r.current_temp_f, url: "https://snowway.app/resorts/#{r.slug}" }
    end

    def region(r) = [ r.state_province, r.country ].compact_blank.uniq.join(", ")
  end
end
