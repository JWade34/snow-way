namespace :search do
  desc "Queue a 30-day Google/Bing backfill when a connected source has no data yet (runs on deploy)"
  task backfill_if_empty: :environment do
    missing = []
    missing << "google" if SearchConsole.configured? && !SearchStat.exists?(source: "google")
    missing << "bing" if BingWebmaster.configured? && !SearchStat.exists?(source: "bing")
    if missing.any?
      SearchStatsSyncJob.perform_later(days: 30)
      puts "queued 30-day search backfill (missing: #{missing.join(", ")})"
    end
  end
end

namespace :seo do
  desc "Apply new entries from db/seo_proposals.yml through ChangeGuard (runs on deploy)"
  task apply_proposals: :environment do
    proposals = YAML.load_file(Rails.root.join("db/seo_proposals.yml")) || []
    proposals.each do |p|
      p = p.transform_keys(&:to_s)
      next if SiteChange.exists?(path: p["path"], kind: p["kind"], after_value: p["value"])
      change = SiteChange.propose!(path: p["path"], kind: p["kind"], value: p["value"], reason: p["reason"], origin: p["origin"] || "claude")
      puts "#{change.status}: #{change.kind} #{change.path} (#{change.result["guard"]})"
    end
  end
end
