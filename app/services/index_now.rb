require "net/http"

# Tells Bing, Yandex, Seznam, Naver (and through Bing, ChatGPT search) which URLs changed.
# https://www.indexnow.org/documentation
module IndexNow
  KEY = "0978a56ee30e31bf9cdd318208e4d055".freeze
  HOST = "snowway.app".freeze
  ENDPOINT = URI("https://api.indexnow.org/indexnow")
  CACHE_KEY = "index_now:last_submitted_on".freeze

  module_function

  def key_location
    "https://#{HOST}/#{KEY}.txt"
  end

  # Submits at most once per day; forecast pages change daily, and resubmitting more often adds nothing.
  def submit_daily(urls)
    return false unless Rails.env.production?
    return false if Rails.cache.read(CACHE_KEY) == Date.current

    submit(urls).tap { |ok| Rails.cache.write(CACHE_KEY, Date.current, expires_in: 2.days) if ok }
  end

  def submit(urls)
    body = { host: HOST, key: KEY, keyLocation: key_location, urlList: urls.first(10_000) }.to_json
    response = Net::HTTP.post(ENDPOINT, body, "Content-Type" => "application/json; charset=utf-8")
    ok = response.code.to_i.between?(200, 202)
    Rails.logger.info "IndexNow: submitted #{urls.size} URLs (HTTP #{response.code})"
    ok
  rescue StandardError => e
    Rails.logger.error "IndexNow submit failed: #{e.message}"
    false
  end
end
