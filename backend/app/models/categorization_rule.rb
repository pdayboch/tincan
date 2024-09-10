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
  belongs_to :category
  belongs_to :subcategory
end
