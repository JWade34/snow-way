require "net/http"

# Tells Bing, Yandex, Seznam, Naver (and through Bing, ChatGPT search) which URLs changed.
# https://www.indexnow.org/documentation
module IndexNow
  KEY = "0978a56ee30e31bf9cdd318208e4d055".freeze
  HOST = "snowway.app".freeze
  ENDPOINT = URI("https://api.indexnow.org/indexnow")
  CACHE_KEY = "index_now:last_submitted_on".freeze
  SUBMITTED_KEY = "index_now:submitted_urls".freeze
  CHANGED_KEY = "index_now:changed_urls".freeze

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

  # Submits URLs that have never been submitted (new pages, resorts, weekly reports). Safe to call often.
  def submit_new(urls)
    return false unless Rails.env.production?

    submitted = Rails.cache.read(SUBMITTED_KEY) || []
    fresh = urls - submitted
    return false if fresh.empty?

    submit(fresh).tap { |ok| Rails.cache.write(SUBMITTED_KEY, (submitted + fresh).uniq) if ok }
  end

  # Resubmits pages whose content changed (url => date last edited). Each url/date pair is sent once.
  def submit_changed(url_dates)
    return false unless Rails.env.production?

    sent = Rails.cache.read(CHANGED_KEY) || {}
    fresh = url_dates.reject { |url, date| sent[url] == date.to_s }
    return false if fresh.empty?

    submit(fresh.keys).tap { |ok| Rails.cache.write(CHANGED_KEY, sent.merge(fresh.transform_values(&:to_s))) if ok }
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
