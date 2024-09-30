# frozen_string_literal: true

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
