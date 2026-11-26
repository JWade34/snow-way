# Digital Asset Links for the Google Play app (a Trusted Web Activity wrapping snowway.app). Android checks this
# file to open the site full screen with no browser bar. The SHA-256 comes from Play Console > App signing.
class AppLinksController < ApplicationController
  ANDROID_PACKAGE = "app.snowway"

  def assetlinks
    fingerprints = ENV["ANDROID_CERT_SHA256"].to_s.split(",").map(&:strip).reject(&:blank?)
    statements = fingerprints.any? ? [ { relation: [ "delegate_permission/common.handle_all_urls" ],
                                         target: { namespace: "android_app", package_name: ANDROID_PACKAGE, sha256_cert_fingerprints: fingerprints } } ] : []
    expires_in 1.hour, public: true
    render json: statements
  end
end
