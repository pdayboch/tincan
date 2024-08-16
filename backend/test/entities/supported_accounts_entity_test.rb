require "test_helper"

class StatementParser::DummyParser < StatementParser::Base
  BANK_NAME = "Dummy Bank"
  ACCOUNT_NAME = "Dummy Account"
  ACCOUNT_TYPE = "dummy type"
  IMAGE_FILENAME = "dummy_filename.png"

  def statement_end_date; end
  def statement_start_date; end
  def statement_balance; end
  def transactions; end
end

class SupportedAccountsEntityTest < ActiveSupport::TestCase
  def setup
    @entity = SupportedAccountsEntity.new
    # Temporarily redefine descendants method to isolate test environment
    StatementParser::Base.singleton_class.class_eval do
      alias_method :original_descendants, :descendants
      define_method(:descendants) { [StatementParser::DummyParser] }
    end
  end

  def test_get_data
    expected_data = [
      {
        accountProvider: "DummyParser",
        bankName: "Dummy Bank",
        accountName: "Dummy Account",
        accountType: "dummy type",
        imageFilename: "images/account_providers/dummy_filename.png",
      },
    ]

    assert_equal expected_data, @entity.get_data
  end

  def test_provider_from_class
    assert_equal "DummyParser",
      SupportedAccountsEntity.provider_from_class(StatementParser::DummyParser)
  end

  def test_class_from_provider_valid
    assert_equal StatementParser::DummyParser, SupportedAccountsEntity.class_from_provider("DummyParser")
  end

  def test_class_from_provider_invalid
    assert_raises(InvalidParser) do
      SupportedAccountsEntity.class_from_provider("NonExistentProvider")
    end
  end
end
