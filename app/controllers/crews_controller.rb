# Ski crews: one link for the group chat. Friends add their pass and see where they can all ski, ranked by snow.
# No accounts. Each member is remembered by a signed cookie on their own device.
class CrewsController < ApplicationController
  rate_limit to: 20, within: 1.hour, only: [ :create, :join ], with: -> { head :too_many_requests }
  before_action :find_crew, only: [ :show, :join ]

  def new; end

  def create
    crew = Crew.new(name: params[:name].to_s.strip.truncate(40, omission: "").presence || "Ski")
    member = crew.members.build(member_token: SecureRandom.hex(16), name: clean_name, pass: clean_pass)
    if crew.save
      remember(crew, member)
      redirect_to crew_page_path(crew.token, created: 1)
    else
      redirect_to new_crew_path, alert: "Give your crew a name."
    end
  end

  def show
    @me = @crew.members.find_by(member_token: cookies.signed[cookie_key])
    @ranking = @crew.ranking
    @top = @ranking.first&.first
  end

  def join
    @me = @crew.members.find_by(member_token: cookies.signed[cookie_key])
    if @me
      @me.update(name: clean_name || @me.name, pass: clean_pass || @me.pass)
    elsif @crew.members.count < Crew::MAX_MEMBERS
      @me = @crew.members.create(member_token: SecureRandom.hex(16), name: clean_name, pass: clean_pass)
      remember(@crew, @me)
    end
    redirect_to crew_page_path(@crew.token)
  end

  private

  def find_crew
    @crew = Crew.find_by!(token: params[:token])
  end

  def cookie_key = "crew_#{(@crew || Crew.new).token}"

  def remember(crew, member)
    cookies.signed.permanent["crew_#{crew.token}"] = { value: member.member_token, httponly: true, same_site: :lax }
    known = (cookies.signed[:crews].to_s.split(",") + [ crew.token ]).uniq.last(10)
    cookies.signed.permanent[:crews] = { value: known.join(","), httponly: true, same_site: :lax }
  end

  def clean_name = params[:member_name].to_s.strip.gsub(/[<>]/, "").truncate(30, omission: "").presence
  def clean_pass = params[:pass].presence_in(Resort::PICKABLE_PASSES.keys + [ "none" ])
end
