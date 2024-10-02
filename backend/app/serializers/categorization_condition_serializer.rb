# frozen_string_literal: true

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
class CategorizationConditionSerializer < ActiveModel::Serializer
  attributes :id

  attribute :categorizationRuleId do
    object.categorization_rule_id
  end

  attribute :transactionField do
    object.transaction_field
  end

  attribute :matchType do
    object.match_type
  end

  attribute :matchValue do
    object.match_value
  end
end
