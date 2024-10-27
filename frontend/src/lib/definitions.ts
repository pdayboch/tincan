export type Account = {
  id: number,
  bankName: string,
  name: string,
  accountType: string,
  active: boolean,
  deletable: boolean,
  user: { id: number, name: string },
  statementDirectory: string,
  nickname: string
}

export type AccountUpdate = Partial<{
  // Include only the fields that can be updated
  active: boolean;
  statementDirectory: string;
  nickname: string;
}>;

export type CategorizationRule = {
  id: number,
  category: { id: number, name: string },
  subcategory: { id: number, name: string },
  conditions: CategorizationCondition[]
}

export type CategorizationRuleUpdate = Partial<{
  subcategoryId: number,
  conditions: CategorizationConditionUpdate[]
}>

export type CategorizationCondition = {
  id: number,
  categorizationRuleId: number,
  transactionField: string,
  matchType: string,
  matchValue: string
}

export type CategorizationConditionUpdate = Partial<{
  transactionField: string,
  matchType: string,
  matchValue: string
}>

export type Category = {
  id: number,
  name: string,
  categoryType: string,
  hasTransactions: boolean,
  subcategories: Subcategory[]
}

export type CategoryResponse = {
  totalItems: number,
  filteredItems: number,
  categories: Category[]
}

export type Subcategory = {
  id: number,
  name: string,
  categoryId: number,
  hasTransactions: boolean
}

export type SupportedAccount = {
  accountProvider: string,
  bankName: string,
  accountName: string,
  accountType: string
}

export type Transaction = {
  id: number,
  transactionDate: string,
  statementTransactionDate: string,
  amount: number,
  description: string,
  statementDescription: string,
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

export type TransactionUpdate = Partial<{
  // Include only the fields that can be updated
  transactionDate: string;
  amount: number;
  description: string;
  accountId: number,
  statementId: number,
  notes: string;
  subcategoryId: number;
}>;

export type TransactionTrendOverTime = {
  date: string;
  amount: number;
}[];

export type User = {
  id: number,
  name: string,
  email: string
}
