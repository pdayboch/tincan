# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[update destroy]

  # GET /accounts
  def index
    user_ids = params[:userIds]
    account_types = params[:accountTypes]

    data = AccountDataEntity.new(
      user_ids: user_ids,
      account_types: account_types
    ).data

    render json: data
  end

  # POST /accounts
  def create
    account = AccountServices::Create.new(account_create_params).call
    render json: account, status: :created, location: account
  end

  # PATCH/PUT /accounts/1
  def update
    raise UnprocessableEntityError, @account.errors unless @account.update(account_update_params)

    render json: @account
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
    params.permit(:account_provider, :active, :user_id, :statement_directory)
  end

  # Only allow a list of trusted parameters through for update action.
  def account_update_params
    if params[:account_provider].present?
      error = {
        account_provider: ['cannot be updated after account creation.']
      }
      raise UnprocessableEntityError, error
    end

    params.permit(:active, :user_id, :statement_directory)
  end
end
