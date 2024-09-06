module StatementParser
  class WellsFargoAutographCreditCard < Base
    BANK_NAME = "Wells Fargo"
    ACCOUNT_NAME = "Autograph Credit Card"
    ACCOUNT_TYPE = "credit card"

    def statement_end_date
      @statement_end_date ||= begin
        regex = /Statement Period\s+\d{2}\/\d{2}\/\d{4}\s*to\s*(\d{2}\/\d{2}\/\d{4})/

        date_format = "%m/%d/%Y"

        match = @text.match(regex)
        raise("Could not extract statement end date for #{@file_path}") unless match
        raw_date = match[1]
        Date.strptime(raw_date, date_format)
      end
    end

    def statement_start_date
      @statement_start_date ||= begin
        regex = /Statement Period\s+(\d{2}\/\d{2}\/\d{4})\s*to\s*\d{2}\/\d{2}\/\d{4}/

        date_format = "%m/%d/%Y"

        match = @text.match(regex)
        raise("Could not extract statement end date for #{@file_path}") unless match
        raw_date = match[1]
        Date.strptime(raw_date, date_format)
      end
    end

    def statement_balance
      @statement_balance ||= begin
        regex = /New Balance\s+\$([\d,]+\.\d{2})/

        match = @text.match(regex)
        raise("Could not extract statement balance for #{@file_path}") unless match
        match[1].gsub(",", "").to_f
      end
    end

    def transactions
      regex = %r{
        (?:\d{4})?\s+       # Last 4 of card
        (\d{2}\/\d{2})\s+   # Transaction date
        \d{2}\/\d{2}\s+     # Post date
        \w+\s+              # Reference Number
        (.+?)\s{3,}         # Description
        (\d{1,3}(?:,\d{3})*\.\d{2}) # Amount
      }x

      matches = @text.scan(regex)
      matches.map do |match|
        date = parse_transaction_date(match[0])
        description = clean_description(match[1])
        amount = format_amount(match[2], description)

        {
          date: date,
          description: description,
          amount: amount,
        }
      end
    end

    def parse_transaction_date(raw_date)
      # raw date is in the format: mm/dd
      date_format = "%m/%d/%Y"
      transaction_year = calculate_transaction_year(raw_date, date_format)
      Date.strptime("#{raw_date}/#{transaction_year}", date_format)
    end

    def calculate_transaction_year(date_str, date_format)
      date = Date.strptime("#{date_str}/#{statement_end_date.year}", date_format)
      # if the transaction month is higher than the statement end month,
      # that indicates the statement spans multiple years and the transaction
      # happened in the previous year.
      if date.month > statement_end_date.month
        statement_end_date.year - 1
      else
        statement_end_date.year
      end
    end

    def format_amount(amount, description)
      # Remove the commas then convert to float
      amount = amount.gsub(/,/, "").to_f.round(2)

      amount *= -1 unless description.match(/PAYMENT.*THANK YOU/)

      amount
    end

    def clean_description(raw_description)
      raw_description.gsub(/\s+/, ' ')
    end
  end
end
