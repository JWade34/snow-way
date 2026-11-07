require "net/http"

# Asks AI answer engines the questions in config/ai_queries.yml and records whether they cite snowway.app.
# Perplexity (PERPLEXITY_API_KEY) and OpenAI web search (OPENAI_API_KEY) both return source URLs, so the
# check is objective: our domain is in the sources or it isn't. Engines without a key are skipped.
module AiCitations
  QUERIES_FILE = Rails.root.join("config/ai_queries.yml")
  DOMAIN = "snowway.app".freeze

  module_function

  def queries
    YAML.load_file(QUERIES_FILE)
  end

  def engines
    {
      "perplexity" => (ENV["PERPLEXITY_API_KEY"].presence && method(:ask_perplexity)),
      "chatgpt-search" => (ENV["OPENAI_API_KEY"].presence && method(:ask_openai))
    }.compact
  end

  def configured?
    engines.any?
  end

  def run!(on: Date.current)
    engines.each do |engine, ask|
      queries.each do |query|
        record(engine, query, on) { ask.call(query) }
      end
    end
  end

  def record(engine, query, on)
    check = AiCitationCheck.find_or_initialize_by(checked_on: on, engine: engine, query: query)
    result = yield
    ours = result[:sources].select { |u| u.to_s.include?(DOMAIN) }
    check.update!(cited: ours.any?, mentioned: result[:text].to_s.match?(/snow ?way/i), snowway_urls: ours,
                  sources: result[:sources].first(20), answer_excerpt: result[:text].to_s.first(600), error: nil)
  rescue StandardError => e
    check.update!(cited: false, mentioned: false, error: e.message.first(250))
  end

  def ask_perplexity(query)
    body = post("https://api.perplexity.ai/chat/completions", ENV["PERPLEXITY_API_KEY"],
                model: ENV.fetch("PERPLEXITY_MODEL", "sonar"), max_tokens: 600,
                messages: [ { role: "user", content: query } ])
    { text: body.dig("choices", 0, "message", "content"),
      sources: Array(body["citations"]).presence || Array(body["search_results"]).map { |r| r["url"] } }
  end

  def ask_openai(query)
    body = post("https://api.openai.com/v1/responses", ENV["OPENAI_API_KEY"],
                model: ENV.fetch("OPENAI_SEARCH_MODEL", "gpt-4.1-mini"), tools: [ { type: "web_search" } ], input: query)
    message = Array(body["output"]).find { |o| o["type"] == "message" } || {}
    parts = Array(message["content"])
    { text: parts.map { |p| p["text"] }.join("\n"),
      sources: parts.flat_map { |p| Array(p["annotations"]) }.filter_map { |a| a["url"] }.uniq }
  end

  def post(url, key, payload)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 90
    request = Net::HTTP::Post.new(uri, "Authorization" => "Bearer #{key}", "Content-Type" => "application/json")
    request.body = payload.to_json
    response = http.request(request)
    raise "HTTP #{response.code}: #{response.body.to_s.first(200)}" unless response.code.to_i == 200
    JSON.parse(response.body)
  end
end
