require "pdf-reader"

module StatementParser
  class Base
    def initialize(file_path)
      puts("StatementParser Base: parsing #{file_path}") unless ENV["RAILS_ENV"] == "test"
      @file_path = file_path
      @text = get_statement_text
    end

    def statement_end_date
      raise NotImplementedError, "Parser classes must implement the statement_end_date method"
    end

    def statement_start_date
      raise NotImplementedError, "Parser classes must implement the statement_start_date method"
    end

    def statement_balance
      raise NotImplementedError, "Parser classes must implement the statement_balance method"
    end

    def transactions
      raise NotImplementedError, "Parser classes must implement the transactions method"
    end

    private

    def get_statement_text
      reader = PDF::Reader.new(@file_path)
      pages = reader.pages.map(&:text)
      clean_and_join_pages(pages)
    end

    def clean_and_join_pages(pages)
      pages.map do |page|
        page.split("\n").map do |line|
          # Remove leading and trailing whitespace,
          # but preserve internal whitespace.
          line.strip
        end
          .reject(&:empty?)
          .join("\n")
      end
        .join("\n")
    end
  end
end
