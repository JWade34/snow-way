require "net/http"

# Asks AI answer engines the questions in config/ai_queries.yml and records whether they cite snowway.app.
# Every engine returns source URLs, so the check is objective: our domain is in the sources or it isn't.
# Engines without credentials are skipped.
#   perplexity          PERPLEXITY_API_KEY
#   chatgpt-search      OPENAI_API_KEY (Responses API + web search)
#   claude              DATAFORSEO_LOGIN/PASSWORD (Claude with web search, via DataForSEO)
#   gemini              DATAFORSEO_LOGIN/PASSWORD (Gemini with Google Search grounding, via DataForSEO)
#   google-ai-overview  DATAFORSEO_LOGIN/PASSWORD (the AI Overview on a live US Google results page)
# Copilot has no API; it answers from Bing's index, which BING_WEBMASTER_API_KEY and IndexNow already cover.
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
      "chatgpt-search" => (ENV["OPENAI_API_KEY"].presence && method(:ask_openai)),
      "claude" => (dataforseo? && method(:ask_claude)),
      "gemini" => (dataforseo? && method(:ask_gemini)),
      "google-ai-overview" => (dataforseo? && method(:ask_ai_overview))
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
    ours |= Array(result[:source_names]).select { |n| n.to_s.include?(DOMAIN) }
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

  # Claude and Gemini with web search, through DataForSEO's LLM responses API (one login for every engine).
  # Model names match the hub's AI Search Program (ai-search-clients/*/client.yml) so scores are comparable.
  def ask_claude(query) = ask_llm("claude", ENV.fetch("CLAUDE_MODEL", "claude-sonnet-5-5"), query)
  def ask_gemini(query) = ask_llm("gemini", ENV.fetch("GEMINI_MODEL", "gemini-3.8-flash"), query)

  # Gemini's grounding links are Google redirects; the real site is in direct_url or the title (usually the domain).
  def ask_llm(engine, model, query)
    task = dataforseo("ai_optimization/#{engine}/llm_responses/live", user_prompt: query, model_name: model, web_search: true)
    sections = Array(task.dig("result", 0, "items")).flat_map { |i| Array(i["sections"]) }
    notes = sections.flat_map { |sec| Array(sec["annotations"]) }
    { text: sections.map { |sec| sec["text"] }.join("\n"), sources: notes.filter_map { |a| a["direct_url"].presence || a["url"] }.uniq,
      source_names: notes.filter_map { |a| a["title"] }.uniq }
  end

  # Google's AI Overview for the query (US, English). No overview on the page means not cited.
  def ask_ai_overview(query)
    task = dataforseo("serp/google/organic/live/advanced",
                      keyword: query, location_code: 2840, language_code: "en", load_async_ai_overview: true)
    items = Array(task.dig("result", 0, "items"))
    overview = items.find { |i| i["type"] == "ai_overview" }
    raise "no AI Overview shown for this query" unless overview
    { text: Array(overview["items"]).map { |i| i["text"] }.compact.join("\n").presence || overview["text"].to_s,
      sources: Array(overview["references"]).filter_map { |r| r["url"] }.uniq }
  end

  def dataforseo?
    ENV["DATAFORSEO_LOGIN"].present? && ENV["DATAFORSEO_PASSWORD"].present?
  end

  def dataforseo(path, task)
    uri = URI("https://api.dataforseo.com/v3/#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.basic_auth(ENV["DATAFORSEO_LOGIN"], ENV["DATAFORSEO_PASSWORD"])
    request.body = [ task ].to_json
    response = http.request(request)
    raise "HTTP #{response.code}" unless response.code.to_i == 200
    result = JSON.parse(response.body).dig("tasks", 0) || {}
    raise "DataForSEO #{result["status_code"]}: #{result["status_message"]}" unless result["status_code"] == 20000
    result
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
