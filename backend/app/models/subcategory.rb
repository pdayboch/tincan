class Subcategory < ApplicationRecord
  belongs_to :category

  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }
end
