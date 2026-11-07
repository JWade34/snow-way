class AiCitationCheck < ApplicationRecord
  scope :latest_run, -> { where(checked_on: maximum(:checked_on)) }

  def self.rate(checks)
    ok = checks.reject(&:error)
    ok.empty? ? nil : (ok.count(&:cited) * 100.0 / ok.size).round
  end

  # Domains AI engines cite instead of us, most common first.
  def self.competitors(checks, limit: 10)
    checks.flat_map { |c| Array(c.sources) }.filter_map { |u| URI.parse(u).host&.delete_prefix("www.") rescue nil }
      .reject { |h| h.end_with?("snowway.app") }.tally.sort_by { |_, n| -n }.first(limit).to_h
  end
end
