export type TransactionUpdate = Partial<{
  // Include only the fields that can be updated
  transaction_date: string;
  amount: number;
  description: string;
  account_id: number;
  subcategory_name: string;
}>;

export type TransactionsResponse = {
  total_items: number,
  filtered_item: number,
  transactions: Transaction[]
}

export type Transaction = {
  id: number,
  transaction_date: string,
  amount: number,
  description: string,
  account: { id: number, bank: string, name: string }
  user: { id: number, name: string },
  category: { id: number, name: string },
  subcategory: { id: number, name: string }
}

export type Account = {
  id: number,
  bankName: string,
  name: string,
  accountType: string,
  user: string,
}

export type User = {
  id: number,
  name: string
}

export type CategoryResponse = {
  total_items: number,
  filtered_items: number,
  categories: Category[]
}

export type Category = {
  id: number,
  name: string,
  has_transactions: boolean,
  subcategories: Subcategory[]
}

export type Subcategory = {
  id: number,
  name: string,
  has_transactions: boolean
}