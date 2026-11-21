# "Sponsor Snow Way": what's available and a short inquiry form that emails Justin (reply goes to the sender).
class SponsorsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { head :too_many_requests }

  def show
  end

  def create
    @inquiry = params.fetch(:inquiry, {}).permit(:name, :email, :company, :website, :interest, :message, :nickname).to_h
    return head(:ok) if @inquiry["nickname"].present? # honeypot
    if @inquiry["email"].to_s.match?(URI::MailTo::EMAIL_REGEXP) && @inquiry["name"].present?
      GrowthMailer.sponsor_inquiry(@inquiry.except("nickname")).deliver_later
      @sent = true
    else
      @error = "Add your name and a valid email so I can reply."
    end
    render :show, status: (@sent ? :ok : :unprocessable_entity)
  end
end
