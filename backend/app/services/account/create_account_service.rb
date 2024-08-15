class Account::CreateAccountService
  def initialize(params)
    @account_provider = params[:account_provider]
    @user_id = params[:user_id]
    @active = params[:active] || true
    @statement_directory = params[:statement_directory]
  end

  def call
    parser_class = SupportedAccountsEntity.class_from_provider(@account_provider)
    account = Account.new(
      bank_name: parser_class::BANK_NAME,
      name: parser_class::ACCOUNT_NAME,
      account_type: parser_class::ACCOUNT_TYPE,
      active: @active,
      user_id: @user_id,
      statement_directory: @statement_directory,
      parser_class: @account_provider,
    )

    if account.save
      account
    else
      raise ActiveRecord::RecordInvalid, account
    end
  end
end
