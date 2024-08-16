require "test_helper"

class ParseStatementsJobTest < ActiveJob::TestCase
  class StatementParser::MockStatementParser < StatementParser::Base
    def initialize(file_path)
      @file_path = file_path
    end

    def statement_end_date
      Date.new(2023, 1, 31)
    end

    def statement_balance
      1234.56
    end

    def transactions
      [
        { date: Date.new(2023, 1, 1), amount: 100.0, description: "Transaction 1" },
        { date: Date.new(2023, 1, 2), amount: 200.0, description: "Transaction 2" },
      ]
    end
  end

  setup do
    unless defined?(@@root_doc_dir)
      @@root_doc_dir = Dir.mktmpdir
      ENV["ROOT_DOC_DIR"] = @@root_doc_dir.strip
    end

    @statement_directory = "test_account"

    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password",
    )

    @account_directory = File.join(@@root_doc_dir, @statement_directory).strip
    FileUtils.mkdir_p(@statement_directory)

    @year_directory = File.join(@account_directory, "2023").strip
    FileUtils.mkdir_p(@year_directory)

    @pdf_file_path = File.join(@year_directory, "statement.pdf").strip
    File.write(@pdf_file_path, "PDF content")
  end

  teardown do
    FileUtils.rm_rf(@account_directory)
  end

  test "should process statements and transactions" do
    account = @user.accounts.create!(
      bank_name: "Bank",
      name: "Test Account",
      statement_directory: @statement_directory,
      parser_class: "MockStatementParser",
    )

    assert_difference "Statement.count", 1 do
      assert_difference "Transaction.count", 2 do
        ParseStatementsJob.perform_now
      end
    end

    statement = account.statements.last
    assert_equal Date.new(2023, 1, 31), statement.statement_date
    assert_equal 1234.56, statement.statement_balance
    assert_equal @pdf_file_path, statement.pdf_file_path

    transactions = statement.transactions
    assert_equal 2, transactions.count

    transaction1 = transactions.find_by(description: "Transaction 1")
    assert_equal Date.new(2023, 1, 1), transaction1.transaction_date
    assert_equal 100.0, transaction1.amount

    transaction2 = transactions.find_by(description: "Transaction 2")
    assert_equal Date.new(2023, 1, 2), transaction2.transaction_date
    assert_equal 200.0, transaction2.amount
  end

  test "should skip account if statement_directory is blank" do
    @user.accounts.create!(
      bank_name: "Bank",
      name: "Account without statement_dir",
      parser_class: "MockStatementParser",
    )

    assert_no_difference "Statement.count" do
      assert_no_difference "Transaction.count" do
        ParseStatementsJob.perform_now
      end
    end
  end

  test "should skip account if parser_class is blank" do
    @user.accounts.create!(
      bank_name: "Bank",
      name: "Account without parser class",
      statement_directory: @statement_directory,
    )

    assert_no_difference "Statement.count" do
      assert_no_difference "Transaction.count" do
        ParseStatementsJob.perform_now
      end
    end
  end

  test "should skip if statement directory is missing" do
    @user.accounts.create!(
      bank_name: "Bank",
      name: "Account but missing account directory",
      statement_directory: "foo",
      parser_class: "MockStatementParser",
    )

    assert_no_difference "Statement.count" do
      assert_no_difference "Transaction.count" do
        ParseStatementsJob.perform_now
      end
    end
  end

  test "should skip processed files" do
    account = @user.accounts.create!(
      bank_name: "Bank",
      name: "Account with processed statements",
      statement_directory: @statement_directory,
      parser_class: "MockStatementParser",
    )
    account.statements.create!(
      statement_date: Date.new(2023, 1, 31),
      statement_balance: 1234.56,
      pdf_file_path: @pdf_file_path,
    )

    assert_no_difference "Statement.count" do
      assert_no_difference "Transaction.count" do
        ParseStatementsJob.perform_now
      end
    end
  end
end
