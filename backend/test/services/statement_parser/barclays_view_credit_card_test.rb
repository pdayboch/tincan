# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module StatementParser
  class BarclaysViewCreditCardTest < ActiveSupport::TestCase
    setup do
      @file_path = 'path/to/statement.pdf'
    end

    test 'statement_end_date' do
      mock_text = <<~TEXT
        Statement Period 12/20/22 - 01/19/23
        Statement Balance: $1,234.56
        Jan 06          Jan 06      Payment Received CHARLES SCHWA                N/A           -$1,043.69
        Dec 20          Dec 21      KYMA ROSLYN NY                                1,020          $340.00
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_equal Date.new(2023, 1, 19), parser.statement_end_date
    end

    test 'statement_end_date no space format' do
      mock_text = <<~TEXT
        Statement Period 12/20/22-01/19/23
        Statement Balance: $1,234.56
        Dec 20          Dec 21      KYMA ROSLYN NY                                1,020          $340.00
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_equal Date.new(2023, 1, 19), parser.statement_end_date
    end

    test 'raises error when statement_end_date not detected' do
      mock_text = 'Invalid text'
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement end date for #{@file_path}") do
        parser.statement_end_date
      end
    end

    test 'statement_start_date' do
      mock_text = <<~TEXT
        Statement Period 12/20/22 - 01/19/23
        Statement Balance: $1,234.56
        Jan 06          Jan 06      Payment Received CHARLES SCHWA                N/A           -$1,043.69
        Dec 20          Dec 21      KYMA ROSLYN NY                                1,020          $340.00
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_equal Date.new(2022, 12, 20), parser.statement_start_date
    end

    test 'statement_start_date no space format' do
      mock_text = <<~TEXT
        Statement Period 12/20/22-01/19/23
        Statement Balance: $1,234.56
        Dec 20          Dec 21      KYMA ROSLYN NY                                1,020          $340.00
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_equal Date.new(2022, 12, 20), parser.statement_start_date
    end

    test 'raises error when statement_start_date not detected' do
      mock_text = 'Invalid text'
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement start date for #{@file_path}") do
        parser.statement_start_date
      end
    end

    test 'statement_balance' do
      mock_text = <<~TEXT
        Statement Period 12/20/22-01/19/23
        Statement Balance: $1,234.56
        Dec 20          Dec 21      KYMA ROSLYN NY                                1,020          $340.00
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_equal 1234.56, parser.statement_balance
    end

    test 'raises error when statement_balance not detected' do
      mock_text = 'Invalid text'
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement balance for #{@file_path}") do
        parser.statement_balance
      end
    end

    test 'transactions' do
      mock_text = <<~TEXT
        Statement Period 01/01/23 - 01/31/23
        Statement Balance: $1,234.56
        Jan 06          Jan 06      Payment Received CHARLES SCHWA                 N/A           -$1,043.69
        Jan 02          Jan 03      FIRST TRANSACTION                              1,020          $340.00
        Jan 22          Jan 23      EATALY NY SERRA NEW YORK NY                    377            $125.79
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 3, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 1, 6),
        description: 'Payment Received CHARLES SCHWA',
        amount: 1043.69
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 2),
        description: 'FIRST TRANSACTION',
        amount: -340.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 22),
        description: 'EATALY NY SERRA NEW YORK NY',
        amount: -125.79
      }
    end

    test 'multi month statement transactions' do
      mock_text = <<~TEXT
        Statement Period 05/20/24 - 06/19/24
        Statement Balance: $1,234.56
        Jun 06          Jun 06      Payment Received CHARLES SCHWA                  N/A           -$1,043.69
        May 23          May 24      FIRST TRANSACTION                               1,020          $340.00
        Jun 02          Jun 03      EATALY NY SERRA NEW YORK NY                     11             $10.98
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)
      transactions = parser.transactions

      assert_equal 3, transactions.size

      assert_includes transactions, {
        date: Date.new(2024, 6, 6),
        description: 'Payment Received CHARLES SCHWA',
        amount: 1043.69
      }

      assert_includes transactions, {
        date: Date.new(2024, 5, 23),
        description: 'FIRST TRANSACTION',
        amount: -340.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 6, 2),
        description: 'EATALY NY SERRA NEW YORK NY',
        amount: -10.98
      }
    end

    test 'multi year statement transactions' do
      mock_text = <<~TEXT
        Statement Period 12/20/23 - 01/19/24
        Statement Balance: $1,234.56
        Jan 06          Jan 06      Payment Received CHARLES SCHWA                  N/A           -$1,043.69
        Dec 20          Dec 21      FIRST TRANSACTION                               1,020          $340.00
        Jan 02          Jan 03      EATALY NY SERRA NEW YORK NY                     11             $10.98
      TEXT
      BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = BarclaysViewCreditCard.new(@file_path)
      transactions = parser.transactions

      assert_equal 3, transactions.size

      assert_includes transactions, {
        date: Date.new(2024, 1, 6),
        description: 'Payment Received CHARLES SCHWA',
        amount: 1043.69
      }

      assert_includes transactions, {
        date: Date.new(2023, 12, 20),
        description: 'FIRST TRANSACTION',
        amount: -340.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 2),
        description: 'EATALY NY SERRA NEW YORK NY',
        amount: -10.98
      }
    end

    test 'leap day transaction' do
      mock_text = <<~TEXT
        Statement Period 02/20/24 - 03/19/24
        Statement Balance: $1,234.56
        Feb 29      Mar 01          Leap day Restaurant              N/A        $2.29
      TEXT

      Timecop.travel(Date.new(2025, 10, 1)) do
        BarclaysViewCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
        parser = BarclaysViewCreditCard.new(@file_path)
        transactions = parser.transactions

        assert_equal 1, transactions.size

        assert_includes transactions, {
          date: Date.new(2024, 2, 29),
          description: 'Leap day Restaurant',
          amount: -2.29
        }
      end
    end
  end
end
