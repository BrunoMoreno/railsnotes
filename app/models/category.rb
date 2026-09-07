class Category < ApplicationRecord
  has_many :notes, dependent: :destroy

  before_validation :generate_slug, if: -> { title.present? && (slug.blank? || title_changed?) }

  private

  def generate_slug
    self.slug = title.parameterize
  end
end
