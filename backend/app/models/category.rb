# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy

  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }
end
