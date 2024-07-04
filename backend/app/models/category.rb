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
  has_many :transactions

  # Validates that the name is unique
  validates :name, uniqueness: { message: 'already exists' }

  before_destroy :check_transactions

  private

  def check_transactions
    if transactions.any?
      errors.add(:base, 'Cannot delete category with transactions')
      throw(:abort)
    end
  end
end
