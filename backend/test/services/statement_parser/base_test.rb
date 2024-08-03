require "test_helper"

module StatementParser
  class BaseTest < ActiveSupport::TestCase
    def setup
      @file_path = "path/to/statement.pdf"

      # Mock the PDF::Reader
      reader_mock = Minitest::Mock.new
      reader_mock.expect :pages,
                         [
                           OpenStruct.new(text: " Page 1 text \n Line 2 \n\n"),
                           OpenStruct.new(text: " Line 3 \n\n Line 4 "),
                         ]
      PDF::Reader.stub :new, reader_mock do
        @base = Base.new(@file_path)
      end
    end

    def test_initialize
      assert_equal @file_path, @base.instance_variable_get(:@file_path)
      expected_text = "Page 1 text\nLine 2\nLine 3\nLine 4"
      assert_equal expected_text, @base.instance_variable_get(:@text)
    end

    def test_statement_end_date_raises_not_implemented_error
      assert_raises(NotImplementedError) { @base.statement_end_date }
    end

    def test_statement_start_date_raises_not_implemented_error
      assert_raises(NotImplementedError) { @base.statement_start_date }
    end

    def test_statement_balance_raises_not_implemented_error
      assert_raises(NotImplementedError) { @base.statement_balance }
    end

    def test_transactions_raises_not_implemented_error
      assert_raises(NotImplementedError) { @base.transactions }
    end
  end
end
