# One day of search performance for a page (query "") or a page + query, from Google or Bing.
class SearchStat < ApplicationRecord
  SOURCES = %w[google bing].freeze

  scope :pages, -> { where(query: "") }
  scope :queries, -> { where.not(query: "") }
  scope :between, ->(range) { where(date: range) }

  # Upserts rows shaped like { date:, source:, page:, query:, clicks:, impressions:, position: }.
  def self.store!(rows)
    return 0 if rows.empty?
    now = Time.current
    upsert_all(rows.map { |r| r.merge(created_at: now, updated_at: now) }, unique_by: :index_search_stats_unique)
    rows.size
  end

  # Weighted average position across rows (by impressions).
  def self.weighted_position(rows)
    impressions = rows.sum(&:impressions)
    return nil if impressions.zero?
    (rows.sum { |r| r.position.to_f * r.impressions } / impressions).round(1)
  end
end
