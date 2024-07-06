class TransactionDataEntity
  # query - include transactions that contain the query in the description, amount, bank, name
  # starting_after - token cursor to get records after the transaction_date + transaction ID
  # account_excludes - array of Account IDs to exclude
  # user_excludes - array of User IDs to exclude
  def initialize(
    query=nil,
    page_size=10,
    starting_after=nil,
    account_excludes=nil,
    user_excludes=nil
  )
    @query = query
    @page_size = page_size
    @starting_after = starting_after
    @account_excludes = account_excludes
    @user_excludes = user_excludes
  end

  def get_data
    {
      total_items: Transaction.count,
      filtered_items: filtered_count,
      transactions: filtered_transactions
    }
  end

  def filtered_transaction_query
    transactions = Transaction
      .includes(:account, {account: :user}, :category, :subcategory)
      .references(:account, :category, :subcategory)

    transactions = transactions
      .where.not(account_id: @account_excludes) if @account_excludes.present?

    transactions = transactions
      .where.not(accounts: { user_id: @user_excludes }) if @user_excludes.present?
    if @query.present?
      transactions = transactions.where("
        transactions.description ILIKE :query OR
        transactions.amount::text ILIKE :query OR
        accounts.bank_name ILIKE :query OR
        accounts.name ILIKE :query OR
        users.name ILIKE :query",
        query: "%#{@query}%"
      )
    end

    transactions
  end

  def filtered_transactions
    paginate_data(filtered_transaction_query).map do |t|
      {
        id: t.id,
        transaction_date: t.transaction_date,
        amount: t.amount,
        description: t.description,
        account: {
          id: t.account.id,
          bank: t.account.bank_name,
          name:  t.account.name
        },
        user: {
          id: t.account.user.id,
          name: t.account.user.name
        },
        category: {
          id: t.category.id,
          name: t.category.name
        },
        subcategory: {
          id: t.subcategory.id,
          name: t.subcategory.name
        }
      }
    end
  end

  def paginate_data(transactions)
    if @starting_after.present?
      date, id = @starting_after.split('+')
      transactions = transactions.where(
        "transaction_date > :date OR
        (transaction_date = :date AND id > :id)",
        date: date, id: id
      )
    end

    transactions
      .order(transaction_date: :desc, id: :desc)
      .limit(@page_size)
  end

  def filtered_count
    filtered_transaction_query.count
  end
end
