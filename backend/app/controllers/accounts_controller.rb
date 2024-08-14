class AccountsController < ApplicationController
  before_action :set_account, only: %i[ update destroy ]
  before_action :transform_params, only: %i[ create update ]

  # GET /accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
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

  # Only allow a list of trusted parameters through.
  def account_params
    params.require(:account).permit(:account_type, :active, :bank_name, :name, :user_id, :statement_directory)
  end

  # Transform flat params to nested and camelCase to snake_case
  def transform_params
    account_params = params.slice(:accountType, :active, :bankName, :deletable, :name, :userId, :statementDirectory)
    account_params = account_params.transform_keys { |key| key.to_s.underscore }
    params[:account] = account_params
  end
end
