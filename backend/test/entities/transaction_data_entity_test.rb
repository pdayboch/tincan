require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  fixtures :transactions, :accounts, :users, :categories, :subcategories

  test "get_data returns the correct structure" do
    data = TransactionDataEntity.new.get_data
    assert data.key?(:total_items)
    assert data.key?(:filtered_items)
    assert data.key?(:transactions)
    assert data[:transactions].is_a?(Array)
  end

  test "get_data retuns transactions sorted by default (transaction_date desc)" do
    entity = TransactionDataEntity.new
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:transaction_date] >= b[:transaction_date] }
  end

  test "get_data retuns transactions sorted by amount asc" do
    entity = TransactionDataEntity
      .new(sort_by: "amount", sort_direction: "asc")
    data = entity.get_data
    assert data[:transactions]
             .each_cons(2)
             .all? { |a, b| a[:amount] <= b[:amount] }
  end

  test "get_data retuns transactions sorted by amount desc" do
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
    @entity = TransactionDataEntity.new(accounts: account_ids)
    data = @entity.get_data
    assert data[:transactions]
             .all? { |t| account_ids.include?(t[:account][:id]) }
    assert data[:transactions]
             .none? { |t| ignored_account_ids.include?(t[:account][:id]) }
  end

  test "get_data returns filtered transactions by users" do
    user_ids = [users(:one).id]
    ignored_user_ids = [users(:two).id]
    @entity = TransactionDataEntity.new(users: user_ids)
    data = @entity.get_data
    assert data[:transactions]
             .all? { |t| user_ids.include?(t[:user][:id]) }
    assert data[:transactions]
             .none? { |t| ignored_user_ids.include?(t[:user][:id]) }
  end

  test "get_data returns filtered transactions by search_string" do
    search_string = "NATalies"
    entity = TransactionDataEntity.new(search_string: search_string)
    data = entity.get_data
    assert data[:transactions]
             .all? { |t| t[:description].downcase.include?(search_string.downcase) }
  end

  test "get_data paginates results" do
    entity = TransactionDataEntity.new(page_size: 3)
    data = entity.get_data
    assert_equal 3, data[:transactions].size
  end

  test "get_data paginates results with a starting_after cursor" do
    transactions = Transaction.order(transaction_date: :desc, id: :desc)
    last_transaction = transactions.offset(3).first
    starting_after = "#{last_transaction.transaction_date}+#{last_transaction.id}"
    entity = TransactionDataEntity.new(page_size: 5, starting_after: starting_after)
    data = entity.get_data
    assert data[:transactions].none? { |t| t[:id] == last_transaction.id }
  end

  test "get_data returns the correct filtered_items count" do
    user_ids = [users(:one).id]
    entity = TransactionDataEntity.new(users: user_ids)
    data = entity.get_data
    filtered_transaction_count = Transaction
      .includes(:account, { account: :user })
      .references(:account)
      .where(accounts: { user_id: user_ids })
      .count
    assert_equal filtered_transaction_count, data[:filtered_items]
  end
end
