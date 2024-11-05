# frozen_string_literal: true

# == Schema Information
#
# Table name: transactions
#
#  id                         :bigint           not null, primary key
#  transaction_date           :date             not null
#  amount                     :decimal(10, 2)   not null
#  description                :text
#  account_id                 :bigint           not null
#  statement_id               :bigint
#  category_id                :bigint           not null
#  subcategory_id             :bigint           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  notes                      :text
#  statement_description      :text
#  statement_transaction_date :date
#  split_from_id              :bigint
#  has_splits                 :boolean          default(FALSE), not null
#
require 'test_helper'

class TransactionUpdateTest < ActiveSupport::TestCase
  test 'updating transaction does not apply categorization rule even on match' do
    cash_and_atm_transaction = transactions(:four)
    assert_equal cash_and_atm_transaction.subcategory.name, 'Cash and Atm'

    subcategory = subcategories(:restaurant)
    category = subcategory.category

    restaurant_rule = CategorizationRule.create!(
      category_id: category.id,
      subcategory_id: subcategory.id
    )

    CategorizationCondition.create!(
      categorization_rule_id: restaurant_rule.id,
      transaction_field: 'description',
      match_type: 'exactly',
      match_value: 'Venda'
    )

    cash_and_atm_transaction.update(description: 'Venda')
    cash_and_atm_transaction.save

    assert_equal cash_and_atm_transaction.subcategory.name, 'Cash and Atm'
  end

  test 'updating transaction syncs the category with subcategory' do
    transaction = transactions(:uncategorized)
    new_subcategory = subcategories(:restaurant)
    transaction.update(subcategory_id: new_subcategory.id)

    assert_equal transaction.subcategory_id, new_subcategory.id
    assert_equal transaction.category_id, new_subcategory.category_id
  end

  test 'updating transaction with nil subcategory_id is invalid' do
    transaction = transactions(:one)
    transaction.update(subcategory_id: nil)

    assert_not transaction.valid?, 'Transaction should be invalid with nil subcategory_id'
    assert_includes transaction.errors.full_messages, 'Subcategory must exist'
  end

  test 'updating transaction description to nil is invalid' do
    transaction = transactions(:one)
    transaction.update(description: nil)

    assert_not transaction.valid?, 'Transaction should be invalid with a missing description'
    assert_includes transaction.errors[:description], 'is required and must have a minimum of three characters'
  end

  test 'updating transaction description to less than 3 characters is invalid' do
    transaction = transactions(:one)
    transaction.update(description: 'a')

    assert_not transaction.valid?, 'Transaction should be invalid with a short description'
    assert_includes transaction.errors[:description], 'is required and must have a minimum of three characters'
  end
end
