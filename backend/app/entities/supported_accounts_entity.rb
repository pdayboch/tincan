class SupportedAccountsEntity
  def get_data
    StatementParser::Base.descendants.map do |parser_class|
      {
        accountProvider: SupportedAccountsEntity.provider_from_class(parser_class),
        bankName: parser_class::BANK_NAME,
        accountName: parser_class::ACCOUNT_NAME,
        accountType: parser_class::ACCOUNT_TYPE,
        imageFilename: image_path_from_filename(parser_class::IMAGE_FILENAME),
      }
    end
  end

  def self.provider_from_class(klass)
    klass.name.split("::")[1]
  end

  def self.class_from_provider(provider)
    class_name = "StatementParser::#{provider}"
    if Object.const_defined?(class_name)
      class_name.constantize
    else
      raise InvalidParser, "Invalid accountProvider: #{provider}"
    end
  end

  private

  def image_path_from_filename(filename)
    "images/account_providers/#{filename}"
  end
end
