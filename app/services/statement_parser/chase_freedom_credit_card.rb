# frozen_string_literal: true

module StatementParser
  class ChaseFreedomCreditCard < Base
    BANK_NAME = 'Chase'
    ACCOUNT_NAME = 'Freedom Credit Card'
    ACCOUNT_TYPE = 'credit card'

    def statement_end_date
      @statement_end_date ||= begin
        date_format = '%m/%d/%y'

        match = @text.match(statement_date_regex)
        raise("Could not extract statement end date for #{@file_path}") unless match

        raw_date = match[2]
        Date.strptime(raw_date, date_format)
      end
    end

    def statement_start_date
      @statement_start_date ||= begin
        date_format = '%m/%d/%y'

        match = @text.match(statement_date_regex)
        raise("Could not extract statement start date for #{@file_path}") unless match

        raw_date = match[1]
        Date.strptime(raw_date, date_format)
      end
    end

    def statement_balance
      @statement_balance ||= begin
        match = @text.match(statement_balance_regex)
        raise("Could not extract statement balance for #{@file_path}") unless match

        balance = match[1] || match[2]
        balance.gsub(/[,$]/, '').to_f
      end
    end

    def transactions
      matches = @text.scan(transaction_regex)
      matches.map do |match|
        {
          date: transaction_date(match[0]),
          description: match[1].strip,
          amount: -format_amount(match[2])
        }
      end
    end

    private

    def transaction_date(transaction_line_formatted_date)
      date_format = '%m/%d'

      transaction_year = calculate_transaction_year(transaction_line_formatted_date)
      Date.strptime("#{transaction_line_formatted_date} #{transaction_year}", "#{date_format} %Y")
    end

    def calculate_transaction_year(date_str)
      transaction_date = Date.strptime("#{date_str}/#{statement_end_date.year}", '%m/%d/%Y')
      # if the transaction month is higher than the statement end month,
      # that indicates the statement spans multiple years and the transaction
      # happened in the previous year.
      if transaction_date.month > statement_end_date.month
        statement_end_date.year - 1
      else
        statement_end_date.year
      end
    end

    def format_amount(amount)
      # Remove the dollar sign and commas, then convert to float
      amount.gsub(/[,$]/, '').to_f.round(2)
    end

    def statement_date_regex
      %r{
        Opening/Closing\sDate
        \s+
        (\d{2}/\d{2}/\d{2}) # 1 - start date
        \s-\s
        (\d{2}/\d{2}/\d{2}) # 2 - end date
      }x
    end

    def statement_balance_regex
      /
        New\sBalance\s+.*\n\s*
        ([-]?\$[\d,]+\.\d{2})
        |
        New\sBalance\n[\s\w:]+[\w\s]+
        ([-]?\$[\d,]+\.\d{2})
      /x
    end

    def transaction_regex
      %r{
        (\d{2}/\d{2}) # 0 - date
        \s{14,}(.+)\s+
        ([-\d,]+\.\d{2}) # 1 - description
      }x
    end
  end
end
