class TransactionDataEntity
  # page_size: number of items to return from the first item after starting_after.
  # starting_after: Token cursor to get records after the transaction_date . transaction ID.
  #                 If not provided, will start at most recent transaction.
  # search_string: Filter for transactions that contain this string in the description, amount, bank, name
  # accounts: array of Account IDs to filter for.
  # users: array of User IDs to filter for.
  # sort_by: the transaction attribute to sort the data by. Valid options are:
  #           transaction_date
  #           amount
  # sort_direction: The direction to sort the sort_by attribute. Valid options are:
  #           asc
  #           desc
  VALID_SORT_BY_ATTRS = %w[transaction_date amount].freeze

  def initialize(params = {})
    check_params(params)

    @page_size = params[:page_size] || 50
    @sort_by = params[:sort_by] || 'transaction_date'
    @sort_direction = params[:sort_direction]&.upcase || 'DESC'
    @starting_after = params[:starting_after]
    @ending_before = params[:ending_before]
    @search_string = params[:search_string]
    @accounts = params[:accounts]
    @users = params[:users]
  end

  def get_data
    transactions = serialized_transactions
    transactions.reverse! if @ending_before.present?

    has_next_page = last_possible_record_id != transactions.last[:id] if transactions.any?
    has_prev_page = first_possible_record_id != transactions.first[:id] if transactions.any?

    {
      meta: {
        totalCount: Transaction.count,
        filteredCount: filtered_count,
        prevPage: has_prev_page ? page_token(transactions.first) : nil,
        nextPage: has_next_page ? page_token(transactions.last) : nil,
      },
      transactions: transactions,
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
    query = query.where(account_id: @accounts) if @accounts.present?
    query = query.where(accounts: { user_id: @users }) if @users.present?
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
    attr_value, id = @ending_before.split('.')
    if @sort_direction == 'ASC'
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

  def check_params(params)
    check_page_size_valid(params)
    check_sort_by_valid(params)
    check_sort_direction_valid(params)
    check_starting_after_valid(params)
    check_ending_before_valid(params)

    if params[:starting_after] && params[:ending_before]
      raise BadRequestError.new(ending_before: ['Cannot specify both startingAfter and endingBefore'])
    end
  end

  def check_page_size_valid(params)
    if params[:page_size] && (params[:page_size].to_i < 3 || params[:page_size].to_i > 1000)
      raise BadRequestError.new(pageSize: ['pageSize must be between 5 and 1000'])
    end
  end

  def check_sort_by_valid(params)
    if params[:sort_by] && VALID_SORT_BY_ATTRS.exclude?(params[:sort_by])
      message = "sort_by parameter must be one of (#{VALID_SORT_BY_ATTRS.join(' | ')})"
      raise BadRequestError.new(sort_by: [message])
    end
  end

  def check_sort_direction_valid(params)
    if params[:sort_direction] && %w[asc desc].exclude?(params[:sort_direction].downcase)
      message = "sortDirection must be one of ('asc' | 'desc')"
      raise BadRequestError.new(sort_direction: [message])
    end
  end

  def check_starting_after_valid(params)
    if params[:starting_after] && params[:sort_by] == 'amount'
      unless page_token_valid?('amount', params[:starting_after])
        message = "startingAfter has invalid format for sortBy 'amount'"
        raise BadRequestError.new(starting_after: [message])
      end
    end

    if params[:starting_after] && (params[:sort_by].nil? || params[:sort_by] == 'transaction_date')
      unless page_token_valid?('transaction', params[:starting_after])
        message = "startingAfter has invalid format for sortBy 'transaction_date'"
        raise BadRequestError.new(starting_after: [message])
      end
    end
  end

  def check_ending_before_valid(params)
    if params[:ending_before] && params[:sort_by] == 'amount'
      unless page_token_valid?('amount', params[:ending_before])
        message = "endingBefore has invalid format for sortBy 'amount'"
        raise BadRequestError.new(endingBefore: [message])
      end
    end

    if params[:ending_before] && (params[:sort_by].nil? || params[:sort_by] == 'transaction_date')
      unless page_token_valid?('transaction', params[:ending_before])
        message = "endingBefore has invalid format for sortBy 'transaction_date'"
        raise BadRequestError.new(ending_before: [message])
      end
    end
  end

  def page_token_valid?(attr, token)
    case attr
    when 'amount'
      /\d+\.\d+\.\d+/.match?(token)
    else
      /\d{4}-\d{2}-\d{2}\.\d+/.match?(token)
    end
  end
end
