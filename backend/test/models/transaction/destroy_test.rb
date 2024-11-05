# frozen_string_literal: true

require 'test_helper'

class TransactionDestroyTest < ActiveSupport::TestCase
  test 'has_splits is set to false after destroying the last split' do
    parent = transactions(:one)
    assert_not parent.has_splits

    split = Transaction.create!(
      transaction_date: parent.transaction_date - 1.day,
      amount: 5.00,
      description: 'split transaction',
      account_id: parent.account_id,
      category_id: parent.subcategory_id,
      split_from_id: parent.id
    )

    parent.reload
    assert parent.has_splits

    split.destroy

    parent.reload
    assert_not parent.has_splits, 'Expected has_splits to be false after destroying the last split'
  end

  test 'has_splits is set to true after destroying one split of multiple' do
    parent = transactions(:one)
    assert_not parent.has_splits

    split = Transaction.create!(
      transaction_date: parent.transaction_date - 1.day,
      amount: 5.00,
      description: 'split transaction',
      account_id: parent.account_id,
      category_id: parent.subcategory_id,
      split_from_id: parent.id
    )

    Transaction.create!(
      transaction_date: parent.transaction_date - 2.days,
      amount: 5.00,
      description: 'split transaction 2',
      account_id: parent.account_id,
      category_id: parent.subcategory_id,
      split_from_id: parent.id
    )

    split.destroy

    parent.reload
    assert parent.has_splits, 'Expected has_splits to be true after destroying one split of many'
  end
end
