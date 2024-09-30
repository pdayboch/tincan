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
require 'test_helper'

class CategorizationConditionTest < ActiveSupport::TestCase
  test 'should match description exactly correctly' do
    transaction = transactions(:one)
    transaction.update(description: 'ATM')
    condition = categorization_conditions(:description_exactly)
    assert condition.matches?(transaction),
           "Condition should match when description exactly matches 'ATM'"
  end

  test 'should not match description exactly when different' do
    transaction = transactions(:one)
    transaction.update(description: 'ATM 1234')
    condition = categorization_conditions(:description_exactly)
    assert_not condition.matches?(transaction),
               "Condition should not match when description is 'ATM 1234' but requires exact match for 'ATM'"
  end

  test 'should match description starts_with correctly' do
    transaction = transactions(:one)
    transaction.update(description: 'ATM 1234')
    condition = categorization_conditions(:description_starts_with)
    assert condition.matches?(transaction),
           "Condition should match when description starts with 'ATM'"
  end

  test 'should not match description starts_with when different' do
    transaction = transactions(:one)
    transaction.update(description: 'BANK ATM')
    condition = categorization_conditions(:description_starts_with)
    assert_not condition.matches?(transaction),
               "Condition should not match when description does not start with 'ATM'"
  end

  test 'should match description ends_with correctly' do
    transaction = transactions(:one)
    transaction.update(description: 'Bank ATM')
    condition = categorization_conditions(:description_ends_with)
    assert condition.matches?(transaction),
           "Condition should match when description ends with 'ATM'"
  end

  test 'should not match description ends_with when different' do
    transaction = transactions(:one)
    transaction.update(description: 'ATM 1234')
    condition = categorization_conditions(:description_ends_with)
    assert_not condition.matches?(transaction),
               "Condition should not match when description does not end with 'ATM'"
  end

  test 'should match amount exactly correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:amount_exactly)
    assert condition.matches?(transaction),
           'Condition should match when amount is 9.99'
  end

  test 'should not match amount exactly when different' do
    transaction = transactions(:one)
    transaction.update(amount: 10.99)
    condition = categorization_conditions(:amount_exactly)
    assert_not condition.matches?(transaction),
               'Condition should not match when amount does not equal 9.99'
  end

  test 'should match amount greater_than correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:amount_greater_than)
    assert condition.matches?(transaction),
           'Condition should match when amount is greater than 9.98'
  end

  test 'should not match amount greater_than when different' do
    transaction = transactions(:one)
    transaction.update(amount: 9.97)
    condition = categorization_conditions(:amount_exactly)
    assert_not condition.matches?(transaction),
               'Condition should not match when amount is not greater than 9.98'
  end

  test 'should match amount less_than correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:amount_less_than)
    assert condition.matches?(transaction),
           'Condition should match when amount is less than 10.00'
  end

  test 'should not match amount less_than when different' do
    transaction = transactions(:one)
    transaction.update(amount: 10.01)
    condition = categorization_conditions(:amount_less_than)
    assert_not condition.matches?(transaction),
               'Condition should not match when amount is not less than 10.00'
  end

  test 'should match date exactly correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:date_exactly)
    assert condition.matches?(transaction),
           'Condition should match when date is 2024-07-02'
  end

  test 'should not match date exactly when different' do
    transaction = transactions(:one)
    transaction.update(transaction_date: Date.new(2024, 7, 3))
    condition = categorization_conditions(:date_exactly)
    assert_not condition.matches?(transaction),
               'Condition should not match when date does not equal 2024-07-02'
  end

  test 'should match date greater_than correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:date_greater_than)
    assert condition.matches?(transaction),
           'Condition should match when date is greater than 2024-07-01'
  end

  test 'should not match date greater_than when different' do
    transaction = transactions(:one)
    transaction.update(transaction_date: Date.new(2024, 6, 30))
    condition = categorization_conditions(:date_greater_than)
    assert_not condition.matches?(transaction),
               'Condition should not match when date is not greater than 2024-07-01'
  end

  test 'should match date less_than correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:date_less_than)
    assert condition.matches?(transaction),
           'Condition should match when date is less than 2024-07-03'
  end

  test 'should not match date less_than when different' do
    transaction = transactions(:one)
    transaction.update(transaction_date: Date.new(2024, 7, 4))
    condition = categorization_conditions(:date_less_than)
    assert_not condition.matches?(transaction),
               'Condition should not match when date is not less than 2024-07-03'
  end

  test 'should match account exactly correctly' do
    transaction = transactions(:one)
    condition = categorization_conditions(:account_exactly)
    assert condition.matches?(transaction),
           'Condition should match when account is one'
  end

  test 'should not match account exactly when different' do
    transaction = transactions(:one)
    other_account = accounts(:two)
    transaction.update(account_id: other_account.id)
    condition = categorization_conditions(:account_exactly)
    assert_not condition.matches?(transaction),
               'Condition should not match when account is not one'
  end

  # Model validations
  test 'should not allow blank transaction_field' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      match_type: 'greater_than',
      match_value: '100'
    )

    assert_not condition.valid?,
               'Condition should be invalid when transaction_field is blank'
    assert_equal({ transaction_field: ["can't be blank"] }, condition.errors.messages)
  end

  test 'should not allow invalid transaction_field' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'foo',
      match_type: 'greater_than',
      match_value: '100'
    )

    assert_not condition.valid?,
               "Condition should be invalid when using 'foo' as transaction_field"
    valid_fields = CategorizationCondition::MATCH_TYPES_FOR_FIELDS.keys.join(', ')
    error_message = { transaction_field: ["foo is invalid. The options are: #{valid_fields}"] }
    assert_equal(error_message, condition.errors.messages)
  end

  test 'should not allow blank match_type' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'description',
      match_value: '100'
    )

    assert_not condition.valid?,
               'Condition should be invalid when match_type is blank'
    assert_equal({ match_type: ["can't be blank"] }, condition.errors.messages)
  end

  test 'should not allow invalid match_type for description' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'description',
      match_type: 'greater_than',
      match_value: '100'
    )

    assert_not condition.valid?,
               "Condition should be invalid when using 'greater_than' for description"
    match_types = CategorizationCondition::MATCH_TYPES_FOR_FIELDS['description']
    message = "is not valid for the field 'description'. Valid match types are: #{match_types.join(', ')}"
    error_message = { match_type: [message] }
    assert_equal(error_message, condition.errors.messages)
  end

  test 'should not allow invalid match_type for amount' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'amount',
      match_type: 'starts_with',
      match_value: '100'
    )

    assert_not condition.valid?,
               "Condition should be invalid when using 'starts_with' for amount"
    match_types = CategorizationCondition::MATCH_TYPES_FOR_FIELDS['amount']
    message = "is not valid for the field 'amount'. Valid match types are: #{match_types.join(', ')}"
    error_message = { match_type: [message] }
    assert_equal(error_message, condition.errors.messages)
  end

  test 'should not allow invalid match_type for date' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'date',
      match_type: 'starts_with',
      match_value: '100'
    )

    assert_not condition.valid?,
               "Condition should be invalid when using 'starts_with' for date"
    match_types = CategorizationCondition::MATCH_TYPES_FOR_FIELDS['date']
    message = "is not valid for the field 'date'. Valid match types are: #{match_types.join(', ')}"
    error_message = { match_type: [message] }
    assert_equal(error_message, condition.errors.messages)
  end

  test 'should not allow invalid match_type for account' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'account',
      match_type: 'starts_with',
      match_value: '100'
    )
    assert_not condition.valid?,
               "Condition should be invalid when using 'starts_with' for account"
    match_types = CategorizationCondition::MATCH_TYPES_FOR_FIELDS['account']
    message = "is not valid for the field 'account'. Valid match types are: #{match_types.join(', ')}"
    error_message = { match_type: [message] }
    assert_equal(error_message, condition.errors.messages)
  end

  test 'should not allow blank match_value' do
    rule = categorization_rules(:one)
    condition = CategorizationCondition.new(
      categorization_rule_id: rule.id,
      transaction_field: 'amount',
      match_type: 'greater_than'
    )

    assert_not condition.valid?,
               'Condition should be invalid when match_value is blank'
    assert_equal({ match_value: ["can't be blank"] }, condition.errors.messages)
  end
end
