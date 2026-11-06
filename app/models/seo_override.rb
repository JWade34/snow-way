# A title and/or meta description that replaces a page's built-in one. Created only through SiteChange.
class SeoOverride < ApplicationRecord
  validates :path, presence: true, uniqueness: true
  validates :title, length: { maximum: 70 }, allow_blank: true
  validates :description, length: { in: 50..160 }, allow_blank: true

  def self.for_path(path)
    find_by(path: path)
  end
end
