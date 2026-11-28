# Optional tips to support Snow Way, paid through Stripe Payment Links (no account, no card data on our side).
# Each option shows only when its Railway variable holds the Payment Link URL.
# The iPhone app shows them only on the US App Store, where Apple allows links to outside payments (3.1.1(a)).
module TipJar
  # The footer's original Stripe link ("Buy me a lift ticket"), used for hot chocolate until TIP_HOT_CHOCOLATE_URL is set.
  ORIGINAL_LINK = "https://buy.stripe.com/fZuaEY4VR8wi4ldfoG6Ri05"

  # price shows next to the label only when its *_PRICE variable is set (e.g. "$5"), so it always matches Stripe.
  Option = Data.define(:key, :label, :emoji, :env, :fallback) do
    def url = ENV[env].presence || fallback
    def price = ENV["#{env.delete_suffix("_URL")}_PRICE"].presence
  end

  OPTIONS = [
    Option.new(key: "hot_chocolate", label: "Buy me a hot chocolate", emoji: "☕", env: "TIP_HOT_CHOCOLATE_URL", fallback: ORIGINAL_LINK),
    Option.new(key: "apres", label: "Buy the après round", emoji: "🍻", env: "TIP_APRES_URL", fallback: nil)
  ].freeze

  module_function

  def options = OPTIONS.select(&:url)
  def enabled? = options.any?
end
