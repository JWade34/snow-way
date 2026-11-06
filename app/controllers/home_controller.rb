class HomeController < ApplicationController
  def index
    @top_resort = Resort.top_powder_destination
    @top_resorts = Resort.by_most_snow.limit(5)
    @resort_count = Resort.count
    @faqs = build_faqs
  end

  private

  def build_faqs
    faqs = []
    if @top_resort
      total = @top_resort.projected_snowfall_7_day
      runners = @top_resorts.drop(1).first(2).select { |r| r.projected_snowfall_7_day > 0 }.map { |r| "#{r.name} (#{r.projected_snowfall_7_day}\")" }
      faqs << { question: "Which ski resort is getting the most snow this week?",
                answer: "As of #{Date.current.strftime("%B %-d, %Y")}, #{@top_resort.name} in #{@top_resort.state_province} leads North American ski resorts with #{total}\" of snow forecast over the next 7 days" \
                        "#{runners.any? ? ", followed by #{runners.to_sentence}" : ""}." }
    end
    faqs << { question: "How often are Snow Way's snow forecasts updated?",
              answer: "Every 6 hours. Each update pulls a fresh 16-day forecast for all #{@resort_count} resorts." }
    faqs << { question: "Where does Snow Way's snow forecast data come from?",
              answer: "Forecasts come from Open-Meteo, which blends national weather models, and are calculated for each resort's summit elevation rather than the nearest town." }
    faqs << { question: "How far ahead can you trust a ski resort snow forecast?",
              answer: "Snow forecasts are most reliable within about 3 days and useful out to about 7. Beyond 7 days they show possible storms, not amounts to plan around, which is why Snow Way ranks resorts on the 7-day total." }
    faqs
  end
end
