class AccountsController < ApplicationController
  before_action :set_account, only: %i[ update destroy ]
  before_action :transform_params, only: %i[ create update ]

  # GET /accounts
  def index
    user_ids = params[:userIds]
    account_types = params[:accountTypes]

    data = AccountDataEntity
      .new(user_ids: user_ids, account_types: account_types)
      .get_data

    render json: data
  end

  # POST /accounts
  def create
    begin
      @account = Account::CreateAccountService.new(account_create_params).call
      render json: @account, status: :created, location: @account
    rescue ActiveRecord::RecordInvalid => e
      render json: e.record.errors, status: :unprocessable_entity
    rescue InvalidParser => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if disallowed_update_params.present?
      render json: { error: "Disallowed parameters for update: #{disallowed_update_params.join(", ")}" }, status: :unprocessable_entity
    elsif @account.update(account_update_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a list of trusted parameters through for create action.
  def account_create_params
    params.require(:account).permit(:account_provider, :active, :user_id, :statement_directory)
  end

  # Only allow a list of trusted parameters through for update action.
  def account_update_params
    params.require(:account).permit(:active, :statement_directory)
  end

  # Check for disallowed parameters in the update action.
  def disallowed_update_params
    allowed_params = %w[active statement_directory]
    params[:account].keys - allowed_params
  end

  # Transform flat params to nested and camelCase to snake_case
  def transform_params
    account_params = params.slice(:accountProvider, :active, :userId, :statementDirectory)
    account_params = account_params.transform_keys { |key| key.to_s.underscore }
    params[:account] = account_params
  end
end
