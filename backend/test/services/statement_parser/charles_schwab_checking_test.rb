# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module StatementParser
  class CharlesSchwabCheckingTest < ActiveSupport::TestCase
    setup do
      @file_path = 'path/to/statement.pdf'
    end

    test 'statement_end_date single month' do
      mock_text = <<~TEXT
        Account Number        Statement Period
        FNAME LNAME           1234567890134         November 1-30, 2023
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_equal Date.new(2023, 11, 30), parser.statement_end_date
    end

    test 'statement_end_date multi month' do
      mock_text = <<~TEXT
        Statement Period
        Account Number          December 30, 2023 to
        FNAME LNAME             123456789012      January 31, 2024
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_equal Date.new(2024, 1, 31), parser.statement_end_date
    end

    test 'raises error when statement_end_date not detected' do
      mock_text = 'Invalid text'
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement end date for #{@file_path}") do
        parser.statement_end_date
      end
    end

    test 'statement_start_date single month' do
      mock_text = <<~TEXT
        Account Number        Statement Period
        FNAME LNAME           1234567890134         November 1-30, 2023
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_equal Date.new(2023, 11, 1), parser.statement_start_date
    end

    test 'statement_start_date_multi_month' do
      mock_text = <<~TEXT
        Statement Period
        Account Number          December 30, 2023 to
        FNAME LNAME             123456789012      January 31, 2024
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_equal Date.new(2023, 12, 30), parser.statement_start_date
    end

    test 'raises error when statement_start_date not detected' do
      mock_text = 'Invalid text'
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement start date for #{@file_path}") do
        parser.statement_start_date
      end
    end

    test 'statement_balance' do
      mock_text = <<~TEXT
        11/02    Electronic Withdrawal              $123.45                                        $1,234.56
        CAPITAL ONE CRCARDPMT 1212
        11/30    ATM Fee Rebate                                            $2.75                   $1,234.56
        11/30    Interest Paid                                             $1.23                   $1,234.56
        11/30    Ending Balance                                                                    $1,234.56
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_equal 1234.56, parser.statement_balance
    end

    test 'raises error when statement_balance not detected' do
      mock_text = 'Invalid text'
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement balance for #{@file_path}") do
        parser.statement_balance
      end
    end

    test 'parses transactions' do
      mock_text = <<~TEXT
        Account Number        Statement Period
        FNAME LNAME           1234567890134         November 1-30, 2023
        Activity
        Date
        Posted Description                                                                      Debits                     Credits                   Balance
        11/01    Beginning Balance                                                                                                                 $10,000.50
        11/02    Electronic Withdrawal                                                         $300.00                                             $9,700.50
        APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW
        11/03    Electronic Withdrawal                                                        $1,200.00                                            $8,500.50
        PAYPAL INST XFER 123456
        Page 3 of 8
        © 2023 Charles Schwab Bank, SSB. All rights reserved. Member FDIC.
        Account Number               Statement Period
        FNAME LNAME                                     1234567890134                 November 1-30, 2023
        TM
        Schwab Bank Investor Checking             (continued)                                                          Account Number: 1234567890134
        Activity (continued)
        Date
        Posted Description                                                                      Debits                     Credits                   Balance
        11/13    Electronic Deposit                                                                                      $2,132.17                 $10,632.67
        Company Paycheck IN DIRECT DEP 123456
        11/19    Funds Transfer to Brokerage -2123                                            $5,000.00                                            $5,632.67
        11/30    ATM Fee Rebate                                                                                               $3.50                   $5,636.17
        11/30    Interest Paid                                                                                                $2.54                   $5,638.71
        11/30    Ending Balance                                                                                                                    $5,638.71
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      transactions = parser.transactions
      assert_equal 6, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 11, 2),
        description: 'Electronic Withdrawal APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW',
        amount: -300.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 11, 3),
        description: 'Electronic Withdrawal PAYPAL INST XFER 123456',
        amount: -1200.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 11, 13),
        description: 'Electronic Deposit Company Paycheck IN DIRECT DEP 123456',
        amount: 2132.17
      }

      assert_includes transactions, {
        date: Date.new(2023, 11, 19),
        description: 'Funds Transfer to Brokerage -2123',
        amount: -5000.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 11, 30),
        description: 'ATM Fee Rebate',
        amount: 3.50
      }

      assert_includes transactions, {
        date: Date.new(2023, 11, 30),
        description: 'Interest Paid',
        amount: 2.54
      }
    end

    test 'parses multi month statement transactions' do
      mock_text = <<~TEXT
        Statement Period
        Account Number                 September 30, 2023 to
        FNAME LNAME                          123456789012           October 31, 2023
        Activity
        Date
        Posted Description                                                 Debits                  Credits               Balance
        09/30    Beginning Balance                                                                                       $10,000.50
        09/30    Electronic Withdrawal                                     $300.00                                       $9,700.50
        APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW
        10/13    Electronic Deposit                                                                $2,132.17             $11,832.67
        Company Paycheck IN DIRECT DEP 123456
        10/31    ATM Fee Rebate                                                                    $3.50                 $11,836.17
        10/31    Interest Paid                                                                     $2.54                 $11,838.71
        10/31    Ending Balance                                                                                          $11,838.71
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 9, 30),
        description: 'Electronic Withdrawal APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW',
        amount: -300.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 10, 13),
        description: 'Electronic Deposit Company Paycheck IN DIRECT DEP 123456',
        amount: 2132.17
      }

      assert_includes transactions, {
        date: Date.new(2023, 10, 31),
        description: 'ATM Fee Rebate',
        amount: 3.50
      }

      assert_includes transactions, {
        date: Date.new(2023, 10, 31),
        description: 'Interest Paid',
        amount: 2.54
      }
    end

    test 'parses multi year statement transactions' do
      mock_text = <<~TEXT
        Statement Period
        Account Number                 December 31, 2023 to
        FNAME LNAME                          123456789012           January 31, 2024
        Activity
        Date
        Posted Description                                             Debits                     Credits                  Balance
        12/31    Beginning Balance                                                                                         $10,000.50
        12/31    Electronic Withdrawal                                 $300.00                                             $9,700.50
        APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW
        01/02    Electronic Deposit                                                               $2,132.17                $11,832.67
        Company Paycheck IN DIRECT DEP 123456
        01/31    Interest Paid                                                                    $2.54                    $11,838.71
        01/31    Ending Balance                                                                                            $11,838.71
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      transactions = parser.transactions
      assert_equal 3, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 12, 31),
        description: 'Electronic Withdrawal APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW',
        amount: -300.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 2),
        description: 'Electronic Deposit Company Paycheck IN DIRECT DEP 123456',
        amount: 2132.17
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 31),
        description: 'Interest Paid',
        amount: 2.54
      }
    end

    test 'parses leap day transaction' do
      mock_text = <<~TEXT
        Statement Period
        Account Number                 February 1, 2024 to
        FNAME LNAME                          123456789012           March 1, 2024
        Activity
        Date
        Posted Description                                  Debits                     Credits                  Balance
        02/01    Beginning Balance                                                                              $10,000.50
        02/29    Electronic Withdrawal                      $300.00                                             $9,700.50
        LEAP DAY PAYMENT
        03/01    Ending Balance                                                                                 $11,838.71
      TEXT

      Timecop.travel(Date.new(2025, 10, 1)) do
        CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
        parser = CharlesSchwabChecking.new(@file_path)
        transactions = parser.transactions

        assert_equal 1, transactions.size

        assert_includes transactions, {
          date: Date.new(2024, 2, 29),
          description: 'Electronic Withdrawal LEAP DAY PAYMENT',
          amount: -300.00
        }
      end
    end

    test 'raises error when transaction description matches both credit and debit keywords' do
      mock_text = <<~TEXT
        Account Number        Statement Period
        FNAME LNAME           1234567890134         November 1-30, 2023
        Activity
        Date
        Posted Description                                                                      Debits                     Credits                 Balance
        11/01    Beginning Balance                                                                                                                 $10,000.50
        11/02    Electronic Withdrawal Deposit                                                 $300.00                                             $9,700.50
        APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW
        11/30    Interest Paid                                                                                             $2.54                   $5,638.71
        11/30    Ending Balance                                                                                                                    $5,638.71
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      error = assert_raises(RuntimeError) do
        parser.transactions
      end

      assert_equal  "A description matches both credit and debit keywords in #{@file_path} on 2023-11-02",
                    error.message
    end

    test 'raises error when transaction description matches no keywords' do
      mock_text = <<~TEXT
        Account Number        Statement Period
        FNAME LNAME           1234567890134         November 1-30, 2023
        Activity
        Date
        Posted Description                                                                      Debits                     Credits                 Balance
        11/01    Beginning Balance                                                                                                                 $10,000.50
        11/02    Electronic money byebye                                                       $300.00                                             $9,700.50
        APPLECARD GSBANK PAYMENT 123456~ Tran: ACHDW
        11/30    Interest Paid                                                                                             $2.54                   $5,638.71
        11/30    Ending Balance                                                                                                                    $5,638.71
      TEXT
      CharlesSchwabChecking.any_instance.stubs(:get_statement_text).returns(mock_text)
      parser = CharlesSchwabChecking.new(@file_path)

      error = assert_raises(RuntimeError) do
        parser.transactions
      end

      assert_equal  "Unknown transaction type in #{@file_path} on 2023-11-02",
                    error.message
    end
  end
end
