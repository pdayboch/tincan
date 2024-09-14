# == Schema Information
#
# Table name: categorization_rules
#
#  id             :bigint           not null, primary key
#  category_id    :bigint           not null
#  subcategory_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class CategorizationRule < ApplicationRecord
  has_many :categorization_conditions, dependent: :destroy
  belongs_to :category
  belongs_to :subcategory

  before_validation :sync_category_with_subcategory

  def match?(transaction)
    categorization_conditions.all? do |condition|
      condition.matches?(transaction)
    end
  end

  private

  # Ensure that the category is in sync with the subcategory
  def sync_category_with_subcategory
    self.category = subcategory.category if subcategory
  end
end
