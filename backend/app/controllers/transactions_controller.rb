class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ update destroy ]
  before_action :set_subcategory, only: %i[ create update ]

  # GET /transactions
  def index
    page_size = params[:page_size] ? params[:page_size].to_i : 10
    if page_size < 5 || page_size > 50
      render json: { page_size: ["must be a number between 5 and 50"]}
    end

    query = params[:query] || ''
    startingAfter = params[:startingAfter]
    data = TransactionDataEntity
      .new(query, page_size, startingAfter)
      .get_data

    render json: data
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(
      transaction_params.except(
        :subcategory_name
      )
    )

    @transaction.subcategory = @subcategory ||
      Subcategory.find_by(name: "Uncategorized")
    @transaction.category = @transaction.subcategory.category

    if transaction_params.key?("subcategory_name") &&
      @subcategory.nil?
      @transaction.errors.add(:subcategory, "is invalid")
    end

    # Attempt to save the transaction only if there are no errors
    if @transaction.errors.empty? && @transaction.save
      render json: @transaction, status: :created, location: @transaction
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # PUT /transactions/1
  def update
    @transaction.subcategory = @subcategory if @subcategory
    @transaction.category = @subcategory.category if @subcategory

    if transaction_params.key?("subcategory_name") &&
      @subcategory.nil?
      @transaction.errors.add(:subcategory, "is invalid")
    end

    if @transaction.errors.empty? &&
      @transaction.update(
        transaction_params.except(
          :subcategory_name
        )
      )
      render json: @transaction
    else
      render json: @transaction.errors, status: :unprocessable_entity
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
      name: transaction_params[:subcategory_name]
    )
  end

  # Only allow a list of trusted parameters through.
  wrap_parameters :transaction,
    include: [
      :transaction_date,
      :amount,
      :description,
      :account_id,
      :subcategory_name
    ]

  def transaction_params
    params.require(:transaction)
      .permit(
        :transaction_date,
        :amount,
        :description,
        :account_id,
        :statement_id,
        :subcategory_name
      )
  end
end
