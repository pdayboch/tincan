# frozen_string_literal: true

require 'test_helper'

class TransactionDataEntityPaginateTest < ActiveSupport::TestCase
  test 'data paginates' do
    entity = TransactionDataEntity.new(page_size: 3)
    data = entity.data
    last_transaction = data[:transactions].last

    assert_equal 3, data[:transactions].size
    assert_nil data[:meta][:prevPage]
    assert_equal "#{last_transaction[:transactionDate]}.#{last_transaction[:id]}", data[:meta][:nextPage]
  end

  test 'data paginates with a starting_after cursor with sort_direction desc with next and prev page' do
    # ex: page1: 1/2/24 -> page2: 1/1/24
    # 0 |> 1 2 3 | 4
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    last_transaction = transactions.first
    starting_after = "#{last_transaction.transaction_date}.#{last_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, starting_after: starting_after)
    data = entity.data

    assert(data[:transactions].none? { |t| t[:id] == last_transaction.id })
    assert(data[:transactions].all? { |t| t[:transactionDate] <= last_transaction.transaction_date })
    assert_equal(
      "#{data[:transactions].first[:transactionDate]}.#{data[:transactions].first[:id]}",
      data[:meta][:prevPage]
    )
    assert_equal(
      "#{data[:transactions].last[:transactionDate]}.#{data[:transactions].last[:id]}",
      data[:meta][:nextPage]
    )
  end

  test 'data paginates with a ending_before cursor with sort_direction desc with next and prev page' do
    # ex: page2: 1/1/24 -> page1: 1/2/24
    # 0 (1) 2 3 <|4 5 6
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    first_transaction = transactions.offset(4).first
    ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before)
    data = entity.data

    assert(data[:transactions].none? { |t| t[:id] == first_transaction.id })
    assert(data[:transactions].all? { |t| t[:transactionDate] >= first_transaction.transaction_date })
    assert_equal(
      "#{data[:transactions].first[:transactionDate]}.#{data[:transactions].first[:id]}",
      data[:meta][:prevPage]
    )
    assert_equal(
      "#{data[:transactions].last[:transactionDate]}.#{data[:transactions].last[:id]}",
      data[:meta][:nextPage]
    )
  end

  test 'data paginates with a starting_after cursor with sort_direction asc with next and prev page' do
    # ex: page1: 1/1/24 -> page2: 1/2/24
    # 0 |> 1 2 3 | 4
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    last_transaction = transactions.first
    starting_after = "#{last_transaction.transaction_date}.#{last_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, starting_after: starting_after, sort_direction: 'asc')
    data = entity.data

    assert(data[:transactions].none? { |t| t[:id] == last_transaction.id })
    assert(data[:transactions].all? { |t| t[:transactionDate] >= last_transaction.transaction_date })
    assert_equal(
      "#{data[:transactions].first[:transactionDate]}.#{data[:transactions].first[:id]}",
      data[:meta][:prevPage]
    )
    assert_equal(
      "#{data[:transactions].last[:transactionDate]}.#{data[:transactions].last[:id]}",
      data[:meta][:nextPage]
    )
  end

  test 'data paginates with a ending_before cursor with sort_direction asc' do
    # ex: page2: 1/2/24 -> page1: 1/1/24
    # 0 | 1 2 3 <| 4
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    first_transaction = transactions.last
    ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before, sort_direction: 'asc')
    data = entity.data

    assert(data[:transactions].none? { |t| t[:id] == first_transaction.id })
    assert(data[:transactions].all? { |t| t[:transactionDate] <= first_transaction.transaction_date })
    assert_equal(
      "#{data[:transactions].first[:transactionDate]}.#{data[:transactions].first[:id]}",
      data[:meta][:prevPage]
    )
    assert_equal(
      "#{data[:transactions].last[:transactionDate]}.#{data[:transactions].last[:id]}",
      data[:meta][:nextPage]
    )
  end

  test 'data paginates with a starting_after cursor with no next page with prev page' do
    # 0 1 2 3 4|> (5 6)
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    transactions = transactions.offset(Transaction.count - 2)
    starting_after = "#{transactions.first.transaction_date}.#{transactions.first.id}"
    expected_ending_before = "#{transactions.last.transaction_date}.#{transactions.last.id}"
    entity = TransactionDataEntity.new(page_size: 5, starting_after: starting_after)
    data = entity.data

    assert_nil data[:meta][:nextPage]
    assert_equal expected_ending_before, data[:meta][:prevPage]
  end

  test 'data paginates with a starting_after cursor with next page with no prev page' do
    # |> (0 1 2 3) 4 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    transaction = transactions.offset(3).first
    expected_starting_after = "#{transaction.transaction_date}.#{transaction.id}"
    starting_after = '1900-01-01.0' # definitely no records before this.
    entity = TransactionDataEntity.new(page_size: 4, starting_after: starting_after, sort_direction: 'asc')
    data = entity.data

    assert_equal expected_starting_after, data[:meta][:nextPage]
    assert_nil data[:meta][:prevPage]
  end

  test 'data paginates with a ending_before cursor with no next page with prev page' do
    # 0 1 2 3 (4 5 6) <|
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    first_transaction = transactions.offset(Transaction.count - 3).first
    expected_ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    ending_before = '3000-12-31.999999' # definitely no records after this
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before, sort_direction: 'asc')
    data = entity.data

    assert_equal expected_ending_before, data[:meta][:prevPage]
    assert_nil data[:meta][:nextPage]
  end

  test 'data paginates with a ending_before cursor with next page with no prev page' do
    # (0 1 2) <|3 4 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    transactions = transactions.offset(2)
    ending_before = "#{transactions[1].transaction_date}.#{transactions[1].id}"
    expected_starting_after = "#{transactions.first.transaction_date}.#{transactions.first.id}"
    entity = TransactionDataEntity.new(page_size: 5, ending_before: ending_before, sort_direction: 'asc')
    data = entity.data

    assert_nil data[:meta][:prevPage]
    assert_equal expected_starting_after, data[:meta][:nextPage]
  end

  test 'data paginates results with no next or prev page' do
    entity = TransactionDataEntity.new(page_size: Transaction.count + 2)
    data = entity.data

    assert_nil data[:meta][:prevPage]
    assert_nil data[:meta][:nextPage]
  end
end
