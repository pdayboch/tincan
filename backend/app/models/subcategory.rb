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
  has_many :transactions

  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }

  before_destroy :check_transactions

  private

  def check_transactions
    if transactions.any?
      errors.add(:base, 'Cannot delete subcategory with transactions')
      throw(:abort)
    end
  end
end
