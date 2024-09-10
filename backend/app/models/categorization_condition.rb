# == Schema Information
#
# Table name: categorization_conditions
#
#  id                     :bigint           not null, primary key
#  categorization_rule_id :bigint           not null
#  transaction_field      :string           not null
#  match_type             :string           not null
#  match_value            :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class CategorizationCondition < ApplicationRecord
  belongs_to :categorization_rule
end
