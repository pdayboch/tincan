class TransactionDataEntity
  # page_size: number of items to return from the first item after starting_after.
  # starting_after: Token cursor to get records after the transaction_date . transaction ID.
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
  VALID_SORT_BY_ATTRS = ["transaction_date", "amount"]

  def initialize(
    page_size: 50,
    starting_after: nil,
    ending_before: nil,
    search_string: nil,
    accounts: nil,
    users: nil,
    sort_by: "transaction_date",
    sort_direction: "desc"
  )
    if starting_after.present? && ending_before.present?
      raise ArgumentError, "Cannot specify both starting_after and ending_before parameters."
    end

    if VALID_SORT_BY_ATTRS.exclude?(sort_by)
      raise ArgumentError, "sort_by parameter must be one of (#{VALID_SORT_BY_ATTRS.join(" | ")})"
    end

    @page_size = page_size
    @starting_after = starting_after
    @ending_before = ending_before
    @search_string = search_string
    @accounts = accounts
    @users = users
    @sort_by = sort_by
    @sort_direction = sort_direction.downcase == "asc" ? "ASC" : "DESC"
  end

  def get_data
    transactions = serialized_transactions
    transactions.reverse! if @ending_before.present?

    has_next_page = last_possible_record_id != transactions.last[:id] if transactions.any?
    has_prev_page = first_possible_record_id != transactions.first[:id] if transactions.any?

    {
      total_items: Transaction.count,
      filtered_items: filtered_count,
      transactions: transactions,
      prev_page: has_prev_page ? page_token(transactions.first) : nil,
      next_page: has_next_page ? page_token(transactions.last) : nil,
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
    query.where("
      transactions.description ILIKE :search_string OR \
      transactions.amount::text ILIKE :search_string OR \
      accounts.bank_name ILIKE :search_string OR \
      accounts.name ILIKE :search_string OR \
      users.name ILIKE :search_string",
                search_string: "%#{@search_string}%")
  end

  def serialized_transactions
    transactions = paginate_data(filtered_transaction_query)
    transactions.map { |t| TransactionSerializer.new(t).as_json }
  end

  def paginate_data(query)
    query = apply_pagination_cursor_after(query) if @starting_after.present?
    query = apply_pagination_cursor_before(query) if @ending_before.present?
    query = apply_order(query)
    query = query.limit(@page_size)

    # Reverse the order after limiting to get the last @page_size records
    query = reverse_order(query) if @ending_before.present?

    query
  end

  def apply_order(query)
    query.order("#{@sort_by} #{@sort_direction}", id: @sort_direction)
  end

  def reverse_order(query)
    reversed_order = @sort_direction == "ASC" ? "DESC" : "ASC"
    query.reorder("#{@sort_by} #{reversed_order}", id: reversed_order)
  end

  def apply_pagination_cursor_after(query)
    attr_value, id = @starting_after.split(".")
    if @sort_direction == "ASC"
      query.where("#{@sort_by} > :attr_value OR \
                (#{@sort_by} = :attr_value AND transactions.id > :id)",
                  attr_value: attr_value, id: id)
    else
      query.where("#{@sort_by} < :attr_value OR \
                (#{@sort_by} = :attr_value AND transactions.id < :id)",
                  attr_value: attr_value, id: id)
    end
  end

  def apply_pagination_cursor_before(query)
    attr_value, id = @ending_before.split(".")
    if @sort_direction == "ASC"
      query.where("#{@sort_by} < :attr_value OR \
                (#{@sort_by} = :attr_value AND transactions.id < :id)",
                  attr_value: attr_value, id: id)
    else
      query.where("#{@sort_by} > :attr_value OR \
                (#{@sort_by} = :attr_value AND transactions.id > :id)",
                  attr_value: attr_value, id: id)
    end
  end

  def last_possible_record_id
    @last_possible_record_id ||= apply_order(filtered_transaction_query).last.id
  end

  def first_possible_record_id
    @first_possible_record_id ||= apply_order(filtered_transaction_query).first.id
  end

  # Generate pagination token for the next/prev page
  def page_token(transaction)
    "#{transaction[@sort_by.to_sym]}.#{transaction[:id]}"
  end

  def filtered_count
    filtered_transaction_query.count
  end
end
