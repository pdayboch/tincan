# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module StatementParser
  class WellsFargoAutographCreditCardTest < ActiveSupport::TestCase
    setup do
      @file_path = 'path/to/statement.pdf'
    end

    test 'statement_end_date' do
      mock_text = <<~TEXT
        WELLS FARGO AUTOGRAPH VISA SIGNATURE CARD
        Account ending in 1234
        Statement Period 01/27/2024 to 02/25/2024
        Page 1 of 3
        Wells Fargo Online :                wellsfargo.com                Payment
        24-hour Customer Service:           1-866-229-6633
        Payment Due Date                                          03/21/2024
        We accept all relay calls, including 711              Minimum Payment                     $25.00
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_equal Date.new(2024, 2, 25), parser.statement_end_date
    end

    test 'raises error when statement_end_date not detected' do
      mock_text = 'Invalid text'
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement end date for #{@file_path}") do
        parser.statement_end_date
      end
    end

    test 'statement_start_date' do
      mock_text = <<~TEXT
        WELLS FARGO AUTOGRAPH VISA SIGNATURE CARD
        Account ending in 1234
        Statement Period 01/27/2024 to 02/25/2024
        Page 1 of 3
        Wells Fargo Online :                wellsfargo.com                Payment
        24-hour Customer Service:           1-866-229-6633
        Payment Due Date                                          03/21/2024
        We accept all relay calls, including 711           Minimum Payment                               $25.00
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_equal Date.new(2024, 1, 27), parser.statement_start_date
    end

    test 'raises error when statement_start_date not detected' do
      mock_text = 'Invalid text'
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement start date for #{@file_path}") do
        parser.statement_start_date
      end
    end

    test 'statement_balance' do
      mock_text = <<~TEXT
        Payment Due Date                                          03/21/2024
        We accept all relay calls, including 711                Minimum Payment                       $25.00
        Outside the US call collect:        1-925-825-7600
        New Balance                                                  $123.45
        Send general inquiries to:
        Wells Fargo, PO Box 10347, Des Moines IA 50306-0347
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_equal 123.45, parser.statement_balance
    end

    test 'raises error when statement_balance not detected' do
      mock_text = 'Invalid text'
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement balance for #{@file_path}") do
        parser.statement_balance
      end
    end

    test 'transactions' do
      mock_text = <<~TEXT
        Account ending in 1234
        Statement Period 01/01/2024 to 01/31/2024
        Page 1 of 3
        This balance may be inclusive of other contributing rewards accounts. For up-to-date rewards balance information, or more ways to
        earn and redeem your rewards, visit wellsfargo.com/rewards or call 1-877-517-1358.
        Transactions
        Card     Trans  Post      Reference Number       Description                               Credits      Charges
        Ending   Date   Date
        in
        Payments
        01/03  01/04     7F0Z18F0Z8F0Z8F0Z      PAYMENT - THANK YOU                                  200.00
        01/30  01/30     78F0Z78F0Z8F0Z8F0      PAYMENT - THANK YOU                                  835.55
        TOTAL PAYMENTS FOR THIS PERIOD                                                            $1,035.55
        Purchases, Balance Transfers & Other Charges
        1234      01/26  01/27     7F0Z18F0Z8F0Z8F0Z      CVS/PHARMACY #12345                                      6.39
        1234      01/26  01/27     78F0Z78F0Z8F0Z8F0      SOME CHARGE      # 1800                                 51.13
        NOTICE: SEE REVERSE SIDE FOR IMPORTANT INFORMATION ABOUT YOUR ACCOUNT                         Continued
        Detach and mail with check payable to Wells Fargo. For faster processing, include your account number on your check.
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2024, 1, 3),
        description: 'PAYMENT - THANK YOU',
        amount: 200.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 30),
        description: 'PAYMENT - THANK YOU',
        amount: 835.55
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 26),
        description: 'CVS/PHARMACY #12345',
        amount: -6.39
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 26),
        description: 'SOME CHARGE # 1800',
        amount: -51.13
      }
    end

    test 'multi month statement transactions' do
      mock_text = <<~TEXT
        Account ending in 1234
        Statement Period 01/20/2024 to 02/19/2024
        Page 1 of 3
        This balance may be inclusive of other contributing rewards accounts. For up-to-date rewards balance information, or more ways to
        earn and redeem your rewards, visit wellsfargo.com/rewards or call 1-877-517-1358.
        Transactions
        Card     Trans  Post      Reference Number       Description                               Credits      Charges
        Ending   Date   Date
        in
        Payments
                01/22  01/23     7F0Z18F0Z8F0Z8F0Z      PAYMENT - THANK YOU                          200.00
                02/02  02/03     78F0Z78F0Z8F0Z8F0      PAYMENT - THANK YOU                          835.55
        TOTAL PAYMENTS FOR THIS PERIOD                                                            $1,035.55
        Purchases, Balance Transfers & Other Charges
        1234     01/26  01/27     7F0Z18F0Z8F0Z8F0Z      CVS/PHARMACY #12345                                      6.39
        1234     02/13  02/14     78F0Z78F0Z8F0Z8F0      SOME CHARGE      # 1800                                 51.13
        NOTICE: SEE REVERSE SIDE FOR IMPORTANT INFORMATION ABOUT YOUR ACCOUNT                         Continued
        Detach and mail with check payable to Wells Fargo. For faster processing, include your account number on your check.
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2024, 1, 22),
        description: 'PAYMENT - THANK YOU',
        amount: 200.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 2, 2),
        description: 'PAYMENT - THANK YOU',
        amount: 835.55
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 26),
        description: 'CVS/PHARMACY #12345',
        amount: -6.39
      }

      assert_includes transactions, {
        date: Date.new(2024, 2, 13),
        description: 'SOME CHARGE # 1800',
        amount: -51.13
      }
    end

    test 'multi year statement transactions' do
      mock_text = <<~TEXT
        Account ending in 1234
        Statement Period 12/20/2023 to 01/19/2024
        Page 1 of 3
        This balance may be inclusive of other contributing rewards accounts. For up-to-date rewards balance information, or more ways to
        earn and redeem your rewards, visit wellsfargo.com/rewards or call 1-877-517-1358.
        Transactions
        Card     Trans  Post      Reference Number       Description                               Credits      Charges
        Ending   Date   Date
        in
        Payments
                12/22  01/23     7F0Z18F0Z8F0Z8F0Z      PAYMENT - THANK YOU                          200.00
                01/02  02/03     78F0Z78F0Z8F0Z8F0      PAYMENT - THANK YOU                          835.55
        TOTAL PAYMENTS FOR THIS PERIOD                                                            $1,035.55
        Purchases, Balance Transfers & Other Charges
        1234     12/28  12/29     7F0Z18F0Z8F0Z8F0Z      CVS/PHARMACY #12345                                      6.39
        1234     01/13  01/14     78F0Z78F0Z8F0Z8F0      SOME CHARGE      # 1800                                 51.13
        NOTICE: SEE REVERSE SIDE FOR IMPORTANT INFORMATION ABOUT YOUR ACCOUNT                         Continued
        Detach and mail with check payable to Wells Fargo. For faster processing, include your account number on your check.
      TEXT
      WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = WellsFargoAutographCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 12, 22),
        description: 'PAYMENT - THANK YOU',
        amount: 200.00
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 2),
        description: 'PAYMENT - THANK YOU',
        amount: 835.55
      }

      assert_includes transactions, {
        date: Date.new(2023, 12, 28),
        description: 'CVS/PHARMACY #12345',
        amount: -6.39
      }

      assert_includes transactions, {
        date: Date.new(2024, 1, 13),
        description: 'SOME CHARGE # 1800',
        amount: -51.13
      }
    end

    test 'leap day transaction' do
      mock_text = <<~TEXT
        Account ending in 1234
        Statement Period 02/20/2024 to 03/19/2024
        Page 1 of 3
        This balance may be inclusive of other contributing rewards accounts. For up-to-date rewards balance information, or more ways to
        earn and redeem your rewards, visit wellsfargo.com/rewards or call 1-877-517-1358.
        Transactions
        Card     Trans  Post      Reference Number       Description                               Credits      Charges
        Ending   Date   Date
        in
        Payments
        02/23  02/24     7F0Z18F0Z8F0Z8F0Z      PAYMENT - THANK YOU                                  200.00
        TOTAL PAYMENTS FOR THIS PERIOD                                                            $1,035.55
        Purchases, Balance Transfers & Other Charges
        1234      02/29  03/01     7F0Z18F0Z8F0Z8F0Z      CVS/PHARMACY #12345                                      6.39
        NOTICE: SEE REVERSE SIDE FOR IMPORTANT INFORMATION ABOUT YOUR ACCOUNT                         Continued
        Detach and mail with check payable to Wells Fargo. For faster processing, include your account number on your check.
      TEXT

      Timecop.travel(Date.new(2025, 10, 1)) do
        WellsFargoAutographCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
        parser = WellsFargoAutographCreditCard.new(@file_path)
        transactions = parser.transactions

        assert_equal 2, transactions.size

        assert_includes transactions, {
          date: Date.new(2024, 2, 23),
          description: 'PAYMENT - THANK YOU',
          amount: 200.00
        }

        assert_includes transactions, {
          date: Date.new(2024, 2, 29),
          description: 'CVS/PHARMACY #12345',
          amount: -6.39
        }
      end
    end
  end
end
