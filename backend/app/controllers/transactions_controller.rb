class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[update destroy]
  before_action :set_subcategory, only: %i[create update]

  # GET /transactions
  def index
    data = TransactionDataEntity.new(transaction_read_params).get_data

    render json: data
  end

  # POST /transactions
  def create
    if transaction_write_params.key?('subcategory_name') && @subcategory.nil?
      raise UnprocessableEntityError.new(subcategory_name: ['is invalid'])
    end

    params_without_subcategory = transaction_write_params.except(:subcategory_name)
    transaction = Transaction.new(params_without_subcategory)

    transaction.subcategory = @subcategory

    if transaction.errors.empty? && transaction.save
      render json: transaction, status: :created, location: transaction
    else
      raise UnprocessableEntityError.new(transaction.errors)
    end
  end

  # PUT /transactions/1
  def update
    if transaction_write_params.key?('subcategory_name') && @subcategory.nil?
      raise UnprocessableEntityError.new(subcategory_name: ['is invalid'])
    end

    params_without_subcategory = transaction_write_params.except(:subcategory_name)
    @transaction.update(params_without_subcategory)

    @transaction.subcategory = @subcategory if @subcategory

    if @transaction.errors.empty? && @transaction.save
      render json: @transaction
    else
      raise UnprocessableEntityError.new(@transaction.errors)
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def set_subcategory
    @subcategory = Subcategory.find_by(
      name: transaction_write_params[:subcategory_name],
    )
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
      users: []
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
      :subcategory_name
    )
  end
end
