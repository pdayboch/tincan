require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  fixtures :transactions, :accounts, :users, :categories, :subcategories

  test "get_data returns the correct structure" do
    data = TransactionDataEntity.new.get_data
    assert data.key?(:meta)
    assert data[:meta].key?(:totalCount)
    assert data[:meta].key?(:filteredCount)
    assert data[:meta].key?(:prevPage)
    assert data[:meta].key?(:nextPage)
    assert data.key?(:transactions)
    assert data[:transactions].is_a?(Array)
  end

  test "get_data returns transactions sorted by default (transaction_date desc)" do
    entity = TransactionDataEntity.new
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:transaction_date] >= b[:transaction_date] }
  end

  test "get_data returns transactions sorted by transaction_date asc" do
    entity = TransactionDataEntity.new(sort_direction: "asc")
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:transaction_date] <= b[:transaction_date] }
  end

  test "get_data returns transactions sorted by amount asc" do
    entity = TransactionDataEntity
      .new(sort_by: "amount", sort_direction: "asc")
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:amount] <= b[:amount] }
  end

  test "get_data returns transactions sorted by amount desc" do
    entity = TransactionDataEntity
      .new(sort_by: "amount", sort_direction: "desc")
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:amount] >= b[:amount] }
  end

  test "get_data returns filtered transactions by accounts" do
    account_ids = [accounts(:one).id, accounts(:two).id]
    ignored_account_ids = [accounts(:three).id]
    entity = TransactionDataEntity.new(accounts: account_ids)
    data = entity.get_data
    assert data[:transactions]
             .all? { |t| account_ids.include?(t[:account][:id]) }
    assert data[:transactions]
             .none? { |t| ignored_account_ids.include?(t[:account][:id]) }
  end

  test "get_data returns filtered transactions by users" do
    user_ids = [users(:one).id]
    ignored_user_ids = [users(:two).id]
    entity = TransactionDataEntity.new(users: user_ids)
    data = entity.get_data
    assert data[:transactions]
             .all? { |t| user_ids.include?(t[:user][:id]) }
    assert data[:transactions]
             .none? { |t| ignored_user_ids.include?(t[:user][:id]) }
  end

  test "get_data returns filtered transactions by search_string for description" do
    search_string = "NATalies"
    entity = TransactionDataEntity.new(search_string: search_string)
    data = entity.get_data
    assert_equal 1, data[:meta][:filteredCount], "transaction not found by searching description"
    assert data[:transactions]
             .all? { |t| t[:description].downcase.include?(search_string.downcase) }
  end

  test "get_data returns filtered transactions by search_string for amount" do
    search_string = "2.3"
    entity = TransactionDataEntity.new(search_string: search_string)
    data = entity.get_data
    assert data[:transactions]
             .all? { |t| t[:amount].to_s.include?("2.3") }
  end

  test "get_data returns no transactions for overfiltered search_string" do
    search_string = "abcdegfhijklmnopqrstuvqxyz"
    entity = TransactionDataEntity.new(search_string: search_string)
    data = entity.get_data
    assert_equal 0, data[:meta][:filteredCount]
    assert_equal [], data[:transactions]
  end

  test "get_data paginates" do
    entity = TransactionDataEntity.new(page_size: 3)
    data = entity.get_data
    last_transaction = data[:transactions].last
    assert_equal 3, data[:transactions].size
    assert_nil data[:meta][:prevPage]
    assert_equal "#{last_transaction[:transaction_date]}.#{last_transaction[:id]}", data[:meta][:nextPage]
  end

  test "get_data paginates with a starting_after cursor with sort_direction desc with next and prev page" do
    # ex: page1: 1/2/24 -> page2: 1/1/24
    # 0 1 2|> 3 4 (5) 6
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    last_transaction = transactions.offset(2).first
    starting_after = "#{last_transaction.transaction_date}.#{last_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, starting_after: starting_after)
    data = entity.get_data
    assert data[:transactions].none? { |t| t[:id] == last_transaction.id }
    assert data[:transactions].all? { |t| t[:transaction_date] <= last_transaction.transaction_date }
    assert_equal "#{data[:transactions].first[:transaction_date]}.#{data[:transactions].first[:id]}", data[:meta][:prevPage]
    assert_equal "#{data[:transactions].last[:transaction_date]}.#{data[:transactions].last[:id]}", data[:meta][:nextPage]
  end

  test "get_data paginates with a ending_before cursor with sort_direction desc with next and prev page" do
    # ex: page2: 1/1/24 -> page1: 1/2/24
    # 0 (1) 2 3 <|4 5 6
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    first_transaction = transactions.offset(4).first
    ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before)
    data = entity.get_data
    assert data[:transactions].none? { |t| t[:id] == first_transaction.id }
    assert data[:transactions].all? { |t| t[:transaction_date] >= first_transaction.transaction_date }
    assert_equal "#{data[:transactions].first[:transaction_date]}.#{data[:transactions].first[:id]}", data[:meta][:prevPage]
    assert_equal "#{data[:transactions].last[:transaction_date]}.#{data[:transactions].last[:id]}", data[:meta][:nextPage]
  end

  test "get_data paginates with a starting_after cursor with sort_direction asc with next and prev page" do
    # ex: page1: 1/1/24 -> page2: 1/2/24
    # 0 1 2|> 3 (4) 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    last_transaction = transactions.offset(2).first
    starting_after = "#{last_transaction.transaction_date}.#{last_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, starting_after: starting_after, sort_direction: "asc")
    data = entity.get_data
    assert data[:transactions].none? { |t| t[:id] == last_transaction.id }
    assert data[:transactions].all? { |t| t[:transaction_date] >= last_transaction.transaction_date }
    assert_equal "#{data[:transactions].first[:transaction_date]}.#{data[:transactions].first[:id]}", data[:meta][:prevPage]
    assert_equal "#{data[:transactions].last[:transaction_date]}.#{data[:transactions].last[:id]}", data[:meta][:nextPage]
  end

  test "get_data paginates with a ending_before cursor with sort_direction asc" do
    # ex: page2: 1/2/24 -> page1: 1/1/24
    # 0 (1) 2 3 <|4 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    first_transaction = transactions.offset(4).first
    ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before, sort_direction: "asc")
    data = entity.get_data
    assert data[:transactions].none? { |t| t[:id] == first_transaction.id }
    assert data[:transactions].all? { |t| t[:transaction_date] <= first_transaction.transaction_date }
    assert_equal "#{data[:transactions].first[:transaction_date]}.#{data[:transactions].first[:id]}", data[:meta][:prevPage]
    assert_equal "#{data[:transactions].last[:transaction_date]}.#{data[:transactions].last[:id]}", data[:meta][:nextPage]
  end

  test "get_data paginates with a starting_after cursor with no next page with prev page" do
    # 0 1 2 3 4|> (5 6)
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    transactions = transactions.offset(Transaction.count - 2)
    starting_after = "#{transactions.first.transaction_date}.#{transactions.first.id}"
    expected_ending_before = "#{transactions.last.transaction_date}.#{transactions.last.id}"
    entity = TransactionDataEntity.new(page_size: 5, starting_after: starting_after)
    data = entity.get_data
    assert_nil data[:meta][:nextPage]
    assert_equal expected_ending_before, data[:meta][:prevPage]
  end

  test "get_data paginates with a starting_after cursor with next page with no prev page" do
    # |> (0 1 2 3) 4 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    transaction = transactions.offset(3).first
    expected_starting_after = "#{transaction.transaction_date}.#{transaction.id}"
    starting_after = "1900-01-01.0" # definitely no records before this.
    entity = TransactionDataEntity.new(page_size: 4, starting_after: starting_after, sort_direction: "ASC")
    data = entity.get_data
    assert_equal expected_starting_after, data[:meta][:nextPage]
    assert_nil data[:meta][:prevPage]
  end

  test "get_data paginates with a ending_before cursor with no next page with prev page" do
    # 0 1 2 3 (4 5 6) <|
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    first_transaction = transactions.offset(Transaction.count - 3).first
    expected_ending_before = "#{first_transaction.transaction_date}.#{first_transaction.id}"
    ending_before = "3000-12-31.999999" # definitely no records after this
    entity = TransactionDataEntity.new(page_size: 3, ending_before: ending_before, sort_direction: "ASC")
    data = entity.get_data
    assert_equal expected_ending_before, data[:meta][:prevPage]
    assert_nil data[:meta][:nextPage]
  end

  test "get_data paginates with a ending_before cursor with next page with no prev page" do
    # (0 1 2) <|3 4 5 6
    transactions = Transaction.order(transaction_date: :asc, id: :asc)
    transactions = transactions.offset(2)
    ending_before = "#{transactions[1].transaction_date}.#{transactions[1].id}"
    expected_starting_after = "#{transactions.first.transaction_date}.#{transactions.first.id}"
    entity = TransactionDataEntity.new(page_size: 5, ending_before: ending_before, sort_direction: "ASC")
    data = entity.get_data
    assert_nil data[:meta][:prevPage]
    assert_equal expected_starting_after, data[:meta][:nextPage]
  end

  test "get_data paginates results with no next or prev page" do
    entity = TransactionDataEntity.new(page_size: Transaction.count + 2)
    data = entity.get_data
    assert_nil data[:meta][:prevPage]
    assert_nil data[:meta][:nextPage]
  end

  test "get_data returns the correct filtered_items count" do
    user_ids = [users(:one).id]
    filtered_transaction_count = Transaction
      .includes(:account, { account: :user })
      .references(:account)
      .where(accounts: { user_id: user_ids })
      .count
    entity = TransactionDataEntity.new(users: user_ids)
    data = entity.get_data
    assert_equal filtered_transaction_count, data[:meta][:filteredCount]
  end

  test "initialize raises error when starting_after and ending_before are both populated" do
  end

  test "initialize raises error when sort_by is invalid" do
    error = assert_raises(
      ArgumentError
    ) do
      TransactionDataEntity.new(sort_by: "foo")
    end

    assert_equal "sort_by parameter must be one of (#{TransactionDataEntity::VALID_SORT_BY_ATTRS.join(" | ")})",
      error.message
  end
end
