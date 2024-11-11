# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module StatementParser
  class ChaseAmazonCreditCardTest < ActiveSupport::TestCase
    setup do
      @file_path = 'path/to/statement.pdf'
    end

    test 'statement_end_date' do
      mock_text = <<~TEXT
        ACCOUNT  SUMMARY
        Account Number: 1234 5678 1234 5678
        Previous Balance                                   $0.00
        Payment, Credits                                   $0.00
        Purchases                                       +$426.73
        Cash Advances                                      $0.00
        Balance Transfers                                  $0.00
        Fees Charged                                       $0.00
        Interest Charged                                   $0.00
        New Balance                                      $426.73
        Opening/Closing Date                    12/02/22 - 01/01/23
        Credit Access Line                                $20,400
        Available Credit                                  $20,293
        Cash Access Line                                    $420
        Available for Cash                                  $420
        Past Due Amount                                  $0.00
        Balance over the Credit Access Line              $0.00
        YOUR ACCOUNT MESSAGES
      TEXT
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_equal Date.new(2023, 1, 1), parser.statement_end_date
    end

    test 'raises error when statement_end_date not detected' do
      mock_text = 'Invalid text'
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement end date for #{@file_path}") do
        parser.statement_end_date
      end
    end

    test 'statement_start_date' do
      mock_text = <<~TEXT
        ACCOUNT  SUMMARY
        Account Number: 1234 5678 1234 5678
        Previous Balance                                   $0.00
        Payment, Credits                                   $0.00
        Purchases                                       +$426.23
        Cash Advances                                      $0.00
        Balance Transfers                                  $0.00
        Fees Charged                                       $0.00
        Interest Charged                                   $0.00
        New Balance                                      $106.19
        Opening/Closing Date                    12/02/22 - 01/01/23
        Credit Access Line                                $20,400
        Available Credit                                  $20,293
        Cash Access Line                                    $420
        Available for Cash                                  $420
        Past Due Amount                                  $0.00
        Balance over the Credit Access Line              $0.00
        YOUR ACCOUNT MESSAGES
      TEXT
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_equal Date.new(2022, 12, 2), parser.statement_start_date
    end

    test 'raises error when statement_start_date not detected' do
      mock_text = 'Invalid text'
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement start date for #{@file_path}") do
        parser.statement_start_date
      end
    end

    test 'statement_balance' do
      mock_text = <<~TEXT
        Manage youraccountonline:           CustomerService:
        Mobile:Downloadthe
        1-888-247-4080
        www.chase.com/amazon                                      ChaseMobileapp today
        SCENARIO-4D
        New Balance
        May 2024                                          YOUR       AMAZON         VISA     POINTS
        $45.11
        S   M   T   W    T   F    S                                Previous points balance
      TEXT
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_equal 45.11, parser.statement_balance
    end

    test 'statement_balance extra line' do
      mock_text = <<~TEXT
        Manage youraccountonline:           CustomerService:
        Mobile:Downloadthe
        1-888-247-4080
        www.chase.com/amazon                                      ChaseMobileapp today
        SCENARIO-4D
        New Balance
        May 2024
        YOUR       AMAZON         VISA     POINTS
        $45.11
        S   M   T   W    T   F    S                                Previous points balance
      TEXT
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_equal 45.11, parser.statement_balance
    end

    test 'negative statement_balance' do
      mock_text = <<~TEXT
        Manage youraccountonline:           CustomerService:
        Mobile:Downloadthe
        1-888-247-4080
        www.chase.com/amazon                                      ChaseMobileapp today
        SCENARIO-4D
        New Balance
        May 2024                                          YOUR       AMAZON         VISA     POINTS
        -$45.11
        S   M   T   W    T   F    S                                Previous points balance
      TEXT
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_equal(-45.11, parser.statement_balance)
    end

    test 'raises error when statement_balance not detected' do
      mock_text = 'Invalid text'
      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement balance for #{@file_path}") do
        parser.statement_balance
      end
    end

    test 'transactions' do
      mock_text = <<~TEXT
        Opening/Closing Date                    01/02/23 - 01/31/23
        TabSummary
        ACCOUNT             ACTIVITY
        Date of
        Transaction                              Merchant Name or Transaction Description        $ Amount
        PAYMENTS      AND   OTHER     CREDITS
        01/26                   AUTOMATIC PAYMENT - THANK YOU                                    -406.29
        PURCHASE
        01/20                   CLIPPER SERVICES CONCORD CA                                       20.00
        01/26                   PG&E WEBRECURRING 800-743-5000 CA                                 73.31
        01/28                   NOE VALLEY PET COMPANY SAN FRANCISCO CA                            5.42
      TEXT

      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 1, 26),
        description: 'AUTOMATIC PAYMENT - THANK YOU',
        amount: 406.29
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 20),
        description: 'CLIPPER SERVICES CONCORD CA',
        amount: -20.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 26),
        description: 'PG&E WEBRECURRING 800-743-5000 CA',
        amount: -73.31
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 28),
        description: 'NOE VALLEY PET COMPANY SAN FRANCISCO CA',
        amount: -5.42
      }
    end

    test 'multi month statement transactions' do
      mock_text = <<~TEXT
        Opening/Closing Date                    03/20/23 - 04/19/23
        TabSummary
        ACCOUNT             ACTIVITY
        Date of
        Transaction                              Merchant Name or Transaction Description        $ Amount
        PAYMENTS      AND   OTHER     CREDITS
        03/26                   AUTOMATIC PAYMENT - THANK YOU                                    -406.29
        PURCHASE
        03/20                   CLIPPER SERVICES CONCORD CA                                       20.00
        04/18                   NOE VALLEY PET COMPANY SAN FRANCISCO CA                            5.42
      TEXT

      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 3, transactions.size

      assert_includes transactions, {
        date: Date.new(2023, 3, 26),
        description: 'AUTOMATIC PAYMENT - THANK YOU',
        amount: 406.29
      }

      assert_includes transactions, {
        date: Date.new(2023, 3, 20),
        description: 'CLIPPER SERVICES CONCORD CA',
        amount: -20.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 4, 18),
        description: 'NOE VALLEY PET COMPANY SAN FRANCISCO CA',
        amount: -5.42
      }
    end

    test 'multi year statement transactions' do
      mock_text = <<~TEXT
        Opening/Closing Date                    12/20/22 - 01/19/23
        TabSummary
        ACCOUNT             ACTIVITY
        Date of
        Transaction                              Merchant Name or Transaction Description        $ Amount
        PAYMENTS      AND   OTHER     CREDITS
        12/26                   AUTOMATIC PAYMENT - THANK YOU                                    -406.29
        PURCHASE
        12/21                   CLIPPER SERVICES CONCORD CA                                       20.00
        01/02                   PG&E WEBRECURRING 800-743-5000 CA                                 73.31
        01/15                   NOE VALLEY PET COMPANY SAN FRANCISCO CA                            5.42
      TEXT

      ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseAmazonCreditCard.new(@file_path)

      transactions = parser.transactions
      assert_equal 4, transactions.size

      assert_includes transactions, {
        date: Date.new(2022, 12, 26),
        description: 'AUTOMATIC PAYMENT - THANK YOU',
        amount: 406.29
      }

      assert_includes transactions, {
        date: Date.new(2022, 12, 21),
        description: 'CLIPPER SERVICES CONCORD CA',
        amount: -20.00
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 2),
        description: 'PG&E WEBRECURRING 800-743-5000 CA',
        amount: -73.31
      }

      assert_includes transactions, {
        date: Date.new(2023, 1, 15),
        description: 'NOE VALLEY PET COMPANY SAN FRANCISCO CA',
        amount: -5.42
      }
    end

    test 'leap day transaction' do
      mock_text = <<~TEXT
        Opening/Closing Date                    02/20/24 - 03/19/24
        TabSummary
        ACCOUNT             ACTIVITY
        Date of
        Transaction                              Merchant Name or Transaction Description        $ Amount
        PAYMENTS      AND   OTHER     CREDITS
        02/25                   AUTOMATIC PAYMENT - THANK YOU                                    -406.29
        PURCHASE
        02/29                   CLIPPER SERVICES CONCORD CA                                       20.00
        2024 Totals Year-to-Date
        Total fees charged in 2024                       $0.00
        Total interest charged in 2024                   $0.00
      TEXT

      Timecop.travel(Date.new(2025, 10, 1)) do
        ChaseAmazonCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
        parser = ChaseAmazonCreditCard.new(@file_path)

        transactions = parser.transactions
        assert_equal 2, transactions.size

        assert_includes transactions, {
          date: Date.new(2024, 2, 25),
          description: 'AUTOMATIC PAYMENT - THANK YOU',
          amount: 406.29
        }

        assert_includes transactions, {
          date: Date.new(2024, 2, 29),
          description: 'CLIPPER SERVICES CONCORD CA',
          amount: -20.00
        }
      end
    end
  end
end
