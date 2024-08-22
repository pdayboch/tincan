export type TransactionUpdate = Partial<{
  // Include only the fields that can be updated
  transaction_date: string;
  amount: number;
  description: string;
  notes: string;
  subcategory_name: string;
}>;

export type AccountUpdate = Partial<{
  // Include only the fields that can be updated
  active: boolean;
  statementDirectory: string;
  nickname: string;
}>;

export type Transaction = {
  id: number,
  transaction_date: string,
  statement_transaction_date: string,
  amount: number,
  description: string,
  statement_description: string,
  notes: string,
  account: { id: number, bank: string, name: string }
  user: { id: number, name: string },
  category: { id: number, name: string },
  subcategory: { id: number, name: string }
}

export type TransactionMetaData = {
  totalCount: number,
  filteredCount: number,
  prevPage: string | null
  nextPage: string | null
}

export type TransactionsResponse = {
  meta: TransactionMetaData,
  transactions: Transaction[]
}

export type Account = {
  id: number,
  bankName: string,
  name: string,
  accountType: string,
  active: boolean,
  deletable: boolean,
  userId: number,
  statementDirectory: string,
  nickname: string
}

export type SupportedAccount = {
  accountProvider: string,
  bankName: string,
  accountName: string,
  accountType: string
}

export type User = {
  id: number,
  name: string,
  email: string
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

export type FilterItemType = {
  id: string,
  label: string,
  sublabel: string | null
}