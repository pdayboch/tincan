# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

module StatementParser
  class BaseTest < ActiveSupport::TestCase
    Page = Struct.new(:text)

    setup do
      @file_path = 'path/to/statement.pdf'

      # Mock the PDF::Reader
      reader_mock = Minitest::Mock.new
      reader_mock.expect :pages,
                         [
                           Page.new(text: " Page 1 text \n Line 2 \n\n"),
                           Page.new(text: " Line 3 \n\n Line 4 ")
                         ]
      PDF::Reader.stub :new, reader_mock do
        @base = Base.new(@file_path)
      end
    end

    test 'initialize sets the correct text' do
      assert_equal @file_path, @base.instance_variable_get(:@file_path)
      expected_text = "Page 1 text\nLine 2\nLine 3\nLine 4"
      assert_equal expected_text, @base.instance_variable_get(:@text)
    end

    test 'statement_end_date raises not implemented_error' do
      assert_raises(NotImplementedError) { @base.statement_end_date }
    end

    test 'statement_start_date raises not implemented error' do
      assert_raises(NotImplementedError) { @base.statement_start_date }
    end

    test 'statement_balance raises not implemented error' do
      assert_raises(NotImplementedError) { @base.statement_balance }
    end

    test 'transactions raises not implemented error' do
      assert_raises(NotImplementedError) { @base.transactions }
    end
  end
end
