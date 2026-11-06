require "net/http"

# Publishes a SocialPost to Instagram (and the linked Facebook Page for feed posts) with Meta's official
# Graph API. Needs META_ACCESS_TOKEN (long-lived Page token) and IG_USER_ID; FB_PAGE_ID is optional.
class MetaPublisher
  class Error < StandardError; end

  def self.configured?
    ENV["META_ACCESS_TOKEN"].present? && ENV["IG_USER_ID"].present?
  end

  def initialize(token: ENV["META_ACCESS_TOKEN"], ig_user: ENV["IG_USER_ID"], page: ENV["FB_PAGE_ID"],
                 version: ENV.fetch("META_GRAPH_VERSION", "v24.0"))
    @token, @ig_user, @page, @version = token, ig_user, page, version
  end

  def publish(post)
    caption = post.caption_text
    result = {}
    container = { image_url: post.image_url }
    container[:caption] = caption unless post.story?
    container[:media_type] = "STORIES" if post.story?
    creation = call("#{@ig_user}/media", container)
    wait_until_ready(creation["id"])
    result["ig_media_id"] = call("#{@ig_user}/media_publish", creation_id: creation["id"])["id"]
    if @page.present? && !post.story?
      result["fb_post_id"] = call("#{@page}/photos", url: post.image_url, message: caption)["post_id"]
    end
    result
  end

  private

  def wait_until_ready(id, tries: 10)
    tries.times do
      status = get(id, fields: "status_code")["status_code"]
      return if status.nil? || status == "FINISHED"
      raise Error, "Instagram rejected the media (#{status})" if status == "ERROR"
      sleep 3
    end
  end

  def call(path, params)
    request(Net::HTTP::Post, path, params)
  end

  def get(path, params)
    request(Net::HTTP::Get, path, params)
  end

  def request(klass, path, params)
    uri = URI("https://graph.facebook.com/#{@version}/#{path}")
    params = params.merge(access_token: @token)
    if klass == Net::HTTP::Get
      uri.query = params.to_query
      req = klass.new(uri)
    else
      req = klass.new(uri)
      req.set_form_data(params)
    end
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) { |http| http.request(req) }
    body = JSON.parse(res.body) rescue {}
    raise Error, body.dig("error", "message") || "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    body
  end
end
