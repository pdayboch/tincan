# frozen_string_literal: true

class CategorizationRuleDataEntity
  def data
    base_rule_query.map do |rule|
      CategorizationRuleSerializer.new(rule).as_json
    end
  end

  private

  def base_rule_query
    CategorizationRule
      .includes(:category, :subcategory, :categorization_conditions)
  end
end
