# frozen_string_literal: true

class TransactionsController < ApplicationController
  # GET /transactions
  def index
    data = TransactionDataEntity.new(transaction_read_params).data

    render json: data
  end

  # POST /transactions
  def create
    check_valid_subcategory(transaction_write_params)
    transaction = Transaction.new(transaction_write_params)

    raise UnprocessableEntityError, transaction.errors unless transaction.errors.empty? && transaction.save

    render json: transaction, status: :created, location: transaction
  end

  # PUT /transactions/1
  def update
    check_valid_subcategory(transaction_write_params)
    transaction = Transaction.find(params[:id])
    transaction.update(transaction_write_params)

    raise UnprocessableEntityError, transaction.errors unless transaction.errors.empty? && transaction.save

    render json: transaction
  end

  # DELETE /transactions/1
  def destroy
    transaction = Transaction.find(params[:id])
    transaction.destroy!
  end

  private

  def check_valid_subcategory(transaction_params)
    return unless transaction_params[:subcategory_id]

    error_msg = { subcategory_id: ['is invalid'] }
    raise UnprocessableEntityError, error_msg unless Subcategory.find_by(id: transaction_params[:subcategory_id])
  end

  def transaction_read_params
    params.permit(
      :page_size,
      :sort_by,
      :sort_direction,
      :starting_after,
      :ending_before,
      :search_string,
      accounts: [],
      users: [],
      subcategories: []
    )
  end

  def transaction_write_params
    params.permit(
      :transaction_date,
      :amount,
      :description,
      :account_id,
      :statement_id,
      :notes,
      :subcategory_id
    )
  end
end
