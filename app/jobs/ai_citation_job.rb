# Weekly: are AI answer engines citing snowway.app? No-op until PERPLEXITY_API_KEY or OPENAI_API_KEY is set.
class AiCitationJob < ApplicationJob
  queue_as :default

  def perform
    return unless AiCitations.configured?
    AiCitations.run!
  end
end
