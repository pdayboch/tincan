class Category < ApplicationRecord
  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }
end
