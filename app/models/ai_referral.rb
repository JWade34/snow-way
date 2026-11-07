# Counts visits that arrive from AI assistants, so we can see AI answer traffic next to search traffic.
class AiReferral < ApplicationRecord
  SOURCES = {
    "chatgpt" => /(^|\.)(chatgpt\.com|chat\.openai\.com)$/,
    "perplexity" => /(^|\.)perplexity\.ai$/,
    "claude" => /(^|\.)claude\.ai$/,
    "gemini" => /(^|\.)(gemini\.google\.com|bard\.google\.com)$/,
    "copilot" => /(^|\.)copilot\.microsoft\.com$/,
    "meta-ai" => /(^|\.)meta\.ai$/,
    "deepseek" => /(^|\.)chat\.deepseek\.com$/,
    "you" => /(^|\.)you\.com$/,
    "grok" => /(^|\.)grok\.com$/
  }.freeze

  scope :since, ->(date) { where(visited_on: date..) }

  # ChatGPT adds utm_source=chatgpt.com to links even when the browser strips the referrer.
  def self.source_for(referer, utm_source = nil)
    [ utm_source, (URI.parse(referer.to_s).host rescue nil) ].compact.each do |value|
      host = value.to_s.downcase.sub(/\Ahttps?:\/\//, "").split("/").first.to_s
      SOURCES.each { |name, pattern| return name if host.match?(pattern) }
    end
    nil
  end

  def self.track(source:, path:, on: Date.current)
    upsert({ visited_on: on, source: source, path: path.to_s.first(255), visits: 1, created_at: Time.current, updated_at: Time.current },
           unique_by: %i[visited_on source path], on_duplicate: Arel.sql("visits = ai_referrals.visits + 1, updated_at = excluded.updated_at"))
  end

  def self.totals_by_source(since: 28.days.ago.to_date)
    since(since).group(:source).sum(:visits).sort_by { |_, v| -v }.to_h
  end

  def self.top_pages(since: 28.days.ago.to_date, limit: 10)
    since(since).group(:path).sum(:visits).sort_by { |_, v| -v }.first(limit).to_h
  end
end
