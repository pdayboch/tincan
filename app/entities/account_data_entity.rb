# frozen_string_literal: true

class AccountDataEntity
  # user_ids: array of User IDs to filter for.
  # account_types: array of account types to filter for.
  def initialize(
    user_ids: nil,
    account_types: nil
  )
    @user_ids = user_ids
    @account_types = account_types
  end

  def data
    filtered_account_query.map { |a| AccountSerializer.new(a).as_json }
  end

  private

  def base_account_query
    Account.includes(:user)
  end

  # Apply filters to the base query
  def filtered_account_query
    query = base_account_query
    query = query.where(user_id: @user_ids) if @user_ids.present?
    query = query.where(account_type: @account_types) if @account_types.present?

    query
  end
end
