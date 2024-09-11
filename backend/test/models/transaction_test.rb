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
#
require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test 'create transaction applies categorization rule' do
    account = accounts(:one)
    subcategory = subcategories(:two)
    category = subcategory.category

    rule = CategorizationRule.create!(
      category_id: category.id,
      subcategory_id: subcategory.id
    )

    CategorizationCondition.create!(
      categorization_rule_id: rule.id,
      transaction_field: "description",
      match_type: "exactly",
      match_value: "Venda"
    )

    t = Transaction.create!(
      transaction_date: Date.new(2024,9,10),
      amount: 10.00,
      description: "Venda",
      account_id: account.id
    )

    assert_equal t.subcategory.id, subcategory.id
    assert_equal t.category.id, category.id
  end

  test 'create transaction applies uncategorized with no matching rule' do
    account = accounts(:one)
    subcategory = subcategories(:uncategorized)
    category = subcategory.category

    t = Transaction.create!(
      transaction_date: Date.new(2024,7,2),
      amount: 9.99,
      description: "CVS",
      account_id: account.id
    )

    assert_equal t.subcategory.id, subcategory.id
    assert_equal t.category.id, category.id
  end

  test 'update transaction syncs the category with subcategory' do
    transaction = transactions(:uncategorized)
    new_subcategory = subcategories(:two)
    new_category = new_subcategory.category
    transaction.update(subcategory_id: new_subcategory.id)

    assert_equal transaction.subcategory_id, new_subcategory.id
    assert_equal transaction.category_id, new_category.id
  end
end
