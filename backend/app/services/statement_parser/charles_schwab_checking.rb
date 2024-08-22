module StatementParser
  class CharlesSchwabChecking < Base
    BANK_NAME = "Charles Schwab"
    ACCOUNT_NAME = "Checking"
    ACCOUNT_TYPE = "checking"

    ALL_MONTHS = "January|February|March|April|May|June|July|August|September|October|November|December"
    DEBIT_KEYWORDS = ["withdrawal", "funds transfer to", "debit", "check"]
    CREDIT_KEYWORDS = ["deposit", "funds transfer from", "credit", "interest paid", "atm fee rebate", "money transfer visa direct"]
    INFORMATIONAL_KEYWORDS = ["beginning balance", "ending balance"]

    def statement_end_date
      @statement_end_date ||= begin
          regex = %r{
          # Single month format
          # July 1-30, 2023
          Statement\ Period.*\b
          (#{ALL_MONTHS})
          \s+
          \d{1,2}-(\d{1,2}), # dont capture start day, capture end day
          \s+
          (\d{4}) # capture year
          |
          # Multi month format
          # June 30, 2023 to July 29, 2023
          Statement\ Period.*\b
          (?:#{ALL_MONTHS}) # dont capture start month
          \s+
          \d{1,2},\s+\d{4} # dont capture start day or year
          \s+to\s+.*\b
          (#{ALL_MONTHS}) # capture end month
          \s+
          (\d{1,2}),\s+(\d{4}) # capture end day and year
          }mx

          match = @text.match(regex)
          raise("Could not extract statement end date for #{@file_path}") unless match

          parse_statement_date(match)
        end
    end

    def statement_start_date
      @statement_start_date ||= begin
          regex = %r{
          # Single month format
          # July 1-30, 2023
          Statement\ Period.*\b
          (#{ALL_MONTHS})
          \s+
          (\d{1,2})-\d{1,2}, # capture start day, dont capture end day
          \s+
          (\d{4}) # capture year
          |
          # Multi month format
          # June 30, 2023 to July 29, 2023
          Statement\ Period.*\b
          (#{ALL_MONTHS}) # capture start month
          \s+
          (\d{1,2}),\s+(\d{4}) # capture start day and year
          \s+to\s+.*\b
          (?:#{ALL_MONTHS}) # dont capture end month
          \s+
          \d{1,2},\s+\d{4} # dont capture end day or year
          }mx

          match = @text.match(regex)
          raise("Could not extract statement start date for #{@file_path}") unless match

          parse_statement_date(match)
        end
    end

    def statement_balance
      @statement_balance ||= begin
          regex = /Ending Balance\s+\$([\d,]+\.\d{2})/

          match = @text.match(regex)
          raise("Could not extract statement balance for #{@file_path}") unless match
          match[1].gsub(",", "").to_f
        end
    end

    def transactions
      activity_text = extract_activity_section
      transaction_lines = split_transaction_lines(activity_text)
      transactions = parse_transaction_lines(transaction_lines)
      transactions.reject { |t| t[:amount] == 0.0 }
    end

    private

    def extract_activity_section
      start_regex = /Activity/
      end_regex = /\d{2}\/\d{2}\s+Ending Balance\s+\$[\d,]+\.\d{2}/

      start_index = @text.index(start_regex)
      end_index = @text.index(end_regex) - 1

      raise("Could not find activity section in #{@file_path}") unless start_index && end_index

      @text[start_index..end_index]
    end

    def split_transaction_lines(text)
      text
        .split("\n")
        .map(&:strip)
        .reject(&:empty?)
    end

    def parse_transaction_lines(lines)
      transactions = []
      current_transaction = nil
      pause_parsing = true
      lines.each do |line|
        # Resume parsing if line begins with date (mm/dd)
        pause_parsing = false if line.match(/^\d{2}\/\d{2}/)
        # Pause parsing if end of page
        pause_parsing = true if line.match(/Page \d+ of \d+/)
        # Otherwise, leave pause_parsing as its previous value.

        if pause_parsing
          if current_transaction
            # Finish writing current transaction if one is in progress.
            transactions << current_transaction
            current_transaction = nil
          end
          next
        end

        if line.match(/^\d{2}\/\d{2}/)
          # new transaction
          transactions << current_transaction if current_transaction
          current_transaction = parse_transaction_line(line)
        else
          # continuation of previous transaction description
          current_transaction[:description] += " #{line.strip}" if current_transaction
        end
      end # end of lines

      transactions << current_transaction if current_transaction
      transactions
    end

    def parse_transaction_line(line)
      regex = %r{
        (\d{2}/\d{2})\s{4} # date
        (.+?)\s{2}         # description (non-greedy)
        (\s+.+)            # remainder (debit, credit, balance)
      }x

      matches = line.match(regex)
      date = parse_transaction_date(matches[1])
      description = matches[2]
      remainder = matches[3]
      amount = 0.0

      amount_regex = %r{
        \s+                  # all the whitespaces
        \$([\d,]+\.\d{2})    # the debit or credit amount
        \s+\$[\d,]+\.\d{2}   # remaining whitespaces and balance.
      }x

      is_credit = CREDIT_KEYWORDS.any? { |kw| description.downcase.include?(kw) }
      is_debit = DEBIT_KEYWORDS.any? { |kw| description.downcase.include?(kw) }

      if is_credit && is_debit
        raise("description matches both credit and debit keywords for #{line} in #{@file_path}")
      end

      if is_credit
        matches = remainder.match(amount_regex)
        raise("couldn't extract credit amount from #{line} in #{@file_path}") if matches.nil?
        amount = format_amount(matches[1])
      elsif is_debit
        matches = remainder.match(amount_regex)
        raise("couldn't extract debit amount from #{line} in #{@file_path}") if matches.nil?
        amount = -format_amount(matches[1])
      elsif INFORMATIONAL_KEYWORDS.any? { |kw| description.downcase.include?(kw) }
        amount = 0.0
      else
        raise("unknown transaction type for #{line} in #{@file_path}")
      end

      { date: date,
        description: description,
        amount: amount }
    end

    def parse_transaction_date(date_str)
      month, day = date_str.split("/").map(&:to_i)
      year = statement_end_date.year

      # If the transaction month is greater than the statement end month,
      # it indicates the transaction happened in the previous year.
      if month > statement_end_date.month
        year -= 1
      end

      Date.new(year, month, day)
    end

    def parse_statement_date(match)
      date_format = "%B %d %Y"

      if match[1] # single month format
        month = match[1]
        day = match[2]
        year = match[3]
      else # multi month format
        month = match[4]
        day = match[5]
        year = match[6]
      end

      Date.strptime("#{month} #{day} #{year}", date_format)
    end

    def format_amount(amount)
      # Remove the dollar sign and commas, then convert to float
      amount.gsub(/[,$]/, "").to_f.round(2)
    end
  end
end
