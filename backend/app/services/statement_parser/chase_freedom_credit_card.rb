module StatementParser
  class ChaseFreedomCreditCard < Base
    BANK_NAME = "Chase"
    ACCOUNT_NAME = "Freedom Credit Card"
    ACCOUNT_TYPE = "credit card"
    IMAGE_FILENAME = "chase_freedom.png"

    def statement_end_date
      @statement_end_date ||= begin
          regex = /Opening\/Closing Date\s+\d{2}\/\d{2}\/\d{2} - (\d{2}\/\d{2}\/\d{2})/
          date_format = "%m/%d/%y"

          match = @text.match(regex)
          raise("Could not extract statement end date for #{@file_path}") unless match
          raw_date = match[1]
          Date.strptime(raw_date, date_format)
        end
    end

    def statement_start_date
      @statement_start_date ||= begin
          regex = /Opening\/Closing Date\s+(\d{2}\/\d{2}\/\d{2}) - \d{2}\/\d{2}\/\d{2}/
          date_format = "%m/%d/%y"

          match = @text.match(regex)
          raise("Could not extract statement start date for #{@file_path}") unless match
          raw_date = match[1]
          Date.strptime(raw_date, date_format)
        end
    end

    def statement_balance
      @statement_balance ||= begin
          regex = /New Balance\s+.*\n\s*([-]?\$[\d,]+\.\d{2})/

          match = @text.match(regex)
          raise("Could not extract statement balance for #{@file_path}") unless match
          match[1].gsub(/[,$]/, "").to_f
        end
    end

    def transactions
      regex = /(\d{2}\/\d{2})\s{14,}(.+)\s+([-\d,]+\.\d{2})/
      date_format = "%m/%d"

      matches = @text.scan(regex)
      matches.map do |match|
        transaction_date_str = match[0]
        transaction_year = calculate_transaction_year(transaction_date_str)
        transaction_date = Date.strptime("#{transaction_date_str} #{transaction_year}", "#{date_format} %Y")

        {
          date: transaction_date,
          description: match[1].strip,
          amount: -format_amount(match[2]),
        }
      end
    end

    private

    def calculate_transaction_year(date_str)
      transaction_date = Date.strptime("#{date_str}/#{statement_end_date.year}", "%m/%d/%Y")
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
      amount.gsub(/[,$]/, "").to_f.round(2)
    end
  end
end
