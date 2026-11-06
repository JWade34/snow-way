# Justin's private area. Off (404) until ADMIN_PASSWORD (12+ chars) is set; then HTTP basic auth, user "justin".
class Admin::BaseController < ApplicationController
  rate_limit to: 60, within: 1.minute
  before_action :require_admin
  after_action { response.headers["X-Robots-Tag"] = "noindex, nofollow" }
  layout "admin"

  private

  def require_admin
    password = ENV["ADMIN_PASSWORD"].to_s
    return head(:not_found) if password.length < 12

    authenticate_or_request_with_http_basic("Snow Way admin") do |user, pass|
      ActiveSupport::SecurityUtils.secure_compare(user, "justin") & ActiveSupport::SecurityUtils.secure_compare(pass, password)
    end
  end
end
