class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ update destroy ]
  before_action :set_subcategory, only: %i[ create update ]

  # GET /transactions
  def index
    page_size = params[:pageSize] ? params[:pageSize].to_i : 10
    if page_size < 3 || page_size > 50
      return render json: { pageSize: ["must be a number between 3 and 50"] }
    end

    starting_after = params[:startingAfter]
    ending_before = params[:endingBefore]
    search_string = params[:searchString]
    accounts = params[:accounts]
    users = params[:users]
    sort_by = params[:sortBy] || "transaction_date"
    sort_direction = params[:sortDirection] || "desc"

    data = TransactionDataEntity
      .new(page_size: page_size,
           starting_after: starting_after,
           ending_before: ending_before,
           search_string: search_string,
           accounts: accounts,
           users: users,
           sort_by: sort_by,
           sort_direction: sort_direction)
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
      name: transaction_params[:subcategory_name],
    )
  end

  # Only allow a list of trusted parameters through.
  wrap_parameters :transaction,
    include: [
      :transaction_date,
      :amount,
      :description,
      :account_id,
      :subcategory_name,
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
