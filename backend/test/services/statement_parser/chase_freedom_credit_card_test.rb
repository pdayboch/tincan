# frozen_string_literal: true

require 'test_helper'
require 'timecop'

module StatementParser
  class ChaseFreedomCreditCardTest < ActiveSupport::TestCase
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
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal Date.new(2023, 1, 1), parser.statement_end_date
    end

    test 'raises error when statement_end_date not detected' do
      mock_text = 'Invalid text'
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

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
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal Date.new(2022, 12, 2), parser.statement_start_date
    end

    test 'raises error when statement_start_date not detected' do
      mock_text = 'Invalid text'
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_raises(RuntimeError, "Could not extract statement start date for #{@file_path}") do
        parser.statement_start_date
      end
    end

    test 'statement_balance' do
      mock_text = <<~TEXT
        Manageyour accountonlinat:    CustomerService:      Mobile:Downloadthe
        www.chase.com/cardhelp        1-800-524-3880        ChaseMobileapp today
        SCENARIO-1D
        New Balance
        January 2023             CHASE        FREEDOM:       ULTIMATE
        $406.19
        S   M   T   W    T   F    S           REWARDS®         SUMMARY
        Minimum Payment Due
        31   1    2   3    4   5    6                    Previous points balance                             8,115
        $40.00                      + 1% (1 Pt)/$1 earned on all purchases                94
      TEXT
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal 406.19, parser.statement_balance
    end

    test 'negative statement_balance' do
      mock_text = <<~TEXT
        Manageyour accountonlinat:    CustomerService:      Mobile:Downloadthe
        www.chase.com/cardhelp        1-800-524-3880        ChaseMobileapp today
        SCENARIO-1D
        New Balance
        January 2023             CHASE        FREEDOM:       ULTIMATE
        -$406.19
        S   M   T   W    T   F    S           REWARDS®         SUMMARY
        Minimum Payment Due
        31   1    2   3    4   5    6                    Previous points balance                             8,115
        $40.00                      + 1% (1 Pt)/$1 earned on all purchases                94
      TEXT
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal(-406.19, parser.statement_balance)
    end

    test 'statement_balance second format' do
      mock_text = <<~TEXT
        Manage youraccount onlinat:          CustomerService:       Mobile:Downloadthe
        www.chase.com/cardhelp               1-800-524-3880                   ®
        ChaseMobileapp today
        SCENARIO-1D
        New Balance
        March 2024                                          CHASE        FREEDOM:           ULTIMATE
        S   M    T   W   T    F   S      $406.19
        REWARDS®             SUMMARY
        Minimum Payment Due
        25   26  27  28   29   1   2
        Previous points balance                               71
        $40.00
      TEXT
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal 406.19, parser.statement_balance
    end

    test 'negative statement_balance second format' do
      mock_text = <<~TEXT
        Manage youraccount onlinat:          CustomerService:       Mobile:Downloadthe
        www.chase.com/cardhelp               1-800-524-3880                   ®
        ChaseMobileapp today
        SCENARIO-1D
        New Balance
        March 2024                                          CHASE        FREEDOM:           ULTIMATE
        S   M    T   W   T    F   S      -$406.19
        REWARDS®             SUMMARY
        Minimum Payment Due
        25   26  27  28   29   1   2
        Previous points balance                               71
        $40.00
      TEXT
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

      assert_equal(-406.19, parser.statement_balance)
    end

    test 'raises error when statement_balance not detected' do
      mock_text = 'Invalid text'
      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

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
        2023 Totals Year-to-Date
        Total fees charged in 2023                       $0.00
        Total interest charged in 2023                   $0.00
        Year-to-date totals do not reflect any fee or interest refunds
        yo may ave received.
      TEXT

      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

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
        2023 Totals Year-to-Date
        Total fees charged in 2023                       $0.00
        Total interest charged in 2023                   $0.00
        Year-to-date totals do not reflect any fee or interest refunds
        yo may ave received.
      TEXT

      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

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
        2023 Totals Year-to-Date
        Total fees charged in 2023                       $0.00
        Total interest charged in 2023                   $0.00
        Year-to-date totals do not reflect any fee or interest refunds
        yo may ave received.
      TEXT

      ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
      parser = ChaseFreedomCreditCard.new(@file_path)

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
        Year-to-date totals do not reflect any fee or interest refunds
        yo may ave received.
      TEXT

      Timecop.travel(Date.new(2025, 10, 1)) do
        ChaseFreedomCreditCard.any_instance.stubs(:statement_text).returns(mock_text)
        parser = ChaseFreedomCreditCard.new(@file_path)

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
