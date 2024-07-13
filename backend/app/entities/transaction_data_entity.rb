class TransactionDataEntity
  # page_size: number of items to return from the first item after starting_after.
  # starting_after: Token cursor to get records after the transaction_date + transaction ID.
  #                 If not provided, will start at most recent transaction.
  # query: Filter for transactions that contain the query in the description, amount, bank, name
  # accounts: array of Account IDs to filter for.
  # users: array of User IDs to filter for.
  # sort_by: the transaction attribute to sort the data by. Valid options are:
  #           transaction_date
  #           amount
  # sort_direction: The direction to sort the sort_by attribute. Valid options are:
  #           asc
  #           desc
  def initialize(
    page_size: 50,
    starting_after: nil,
    search_string: nil,
    accounts: nil,
    users: nil,
    sort_by: "transaction_date",
    sort_direction: "desc"
  )
    @page_size = page_size
    @starting_after = starting_after
    @search_string = search_string
    @accounts = accounts
    @users = users
    @sort_by = sort_by
    @sort_direction = sort_direction.downcase == "asc" ? "ASC" : "DESC"
  end

  def get_data
    {
      total_items: Transaction.count,
      filtered_items: filtered_count,
      transactions: filtered_transactions,
    }
  end

  private

  def base_transaction_query
    Transaction
      .includes(:account, { account: :user }, :category, :subcategory)
      .references(:account, :category, :subcategory)
  end

  # Apply filters to the base query
  def filtered_transaction_query
    query = base_transaction_query
    query = query
      .where(account_id: @accounts) if @accounts.present?
    query = query
      .where(accounts: { user_id: @users }) if @users.present?
    query = apply_search_filter(query) if @search_string.present?

    query
  end

  def apply_search_filter(query)
    query.where("transactions.description ILIKE :search_string OR \
        transactions.amount::text ILIKE :search_string OR \
        accounts.bank_name ILIKE :search_string OR \
        accounts.name ILIKE :search_string OR \
        users.name ILIKE :search_string",
                search_string: "%#{@search_string}%")
  end

  def filtered_transactions
    paginate_data(filtered_transaction_query).map do |t|
      TransactionSerializer.new(t).as_json
    end
  end

  def paginate_data(query)
    query = apply_pagination_cursor(query) if @starting_after.present?
    query
      .order("#{@sort_by} #{@sort_direction}", id: @sort_direction)
      .limit(@page_size)
  end

  def apply_pagination_cursor(query)
    date, id = @starting_after.split("+")
    query.where("transaction_date > :date OR \
                (transaction_date = :date AND transactions.id > :id)",
                date: date, id: id)
  end

  def filtered_count
    filtered_transaction_query.count
  end
end
