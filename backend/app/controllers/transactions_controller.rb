class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ update destroy ]
  before_action :set_category, only: %i[ create update ]
  before_action :set_subcategory, only: %i[ create update ]

  # GET /transactions
  def index
    @transactions = Transaction.all

    render json: @transactions
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params.except(:category, :subcategory))

    @transaction.category = @category || Category.find_by(name: "Uncategorized")
    @transaction.subcategory = @subcategory || Subcategory.find_by(name: "Uncategorized")

    if params[:transaction].key?("category") && @category.nil?
      @transaction.errors.add(:category, "is invalid")
    end

    if params[:transaction].key?("subcategory") && @subcategory.nil?
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
    @transaction.category = @category if @category
    @transaction.subcategory = @subcategory if @subcategory

    if params[:transaction].key?("category") && @category.nil?
      @transaction.errors.add(:category, "is invalid")
    end

    if params[:transaction].key?("subcategory") && @subcategory.nil?
      @transaction.errors.add(:subcategory, "is invalid")
    end

    if @transaction.errors.empty? && @transaction.update(transaction_params.except(:category, :subcategory))
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

  def set_category
    @category = Category.find_by(name: params[:transaction][:category])
  end

  def set_subcategory
    @subcategory = Subcategory.find_by(name: params[:transaction][:subcategory])
  end

  # Only allow a list of trusted parameters through.
  def transaction_params
    params.require(:transaction)
      .permit(
        :transaction_date,
        :amount,
        :description,
        :account_id,
        :statement_id,
        :category,
        :subcategory
      )
  end
end
