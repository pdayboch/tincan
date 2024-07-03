# == Schema Information
#
# Table name: subcategories
#
#  id          :bigint           not null, primary key
#  name        :string
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Subcategory < ApplicationRecord
  belongs_to :category

  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }
end
