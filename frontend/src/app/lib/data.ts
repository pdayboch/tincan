import {
  CategoryResponse,
  TransactionsResponse,
  TransactionUpdate,
  Transaction,
  Account,
  User,
  AccountUpdate
} from "./definitions";

export async function fetchCategories(): Promise<CategoryResponse> {
  const url = 'http://127.0.0.1:3005/categories';
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching categories: ${response.status}`);
  }
  const data: CategoryResponse = await response.json();
  return data;
}

export async function fetchUsers(): Promise<User[]> {
  const url = 'http://127.0.0.1:3005/users';
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching users: ${response.status}`);
  }
  const data: User[] = await response.json();
  return data;
}

export async function fetchAccounts(): Promise<Account[]> {
  const url = 'http://127.0.0.1:3005/accounts';
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching accounts: ${response.status}`);
  }
  const data: Account[] = await response.json();
  return data;
}

export async function updateAccount(
  accountId: number,
  updates: AccountUpdate
): Promise<Account> {
  const url = `http://127.0.0.1:3005/accounts/${accountId}`
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error updating account: ${errorMessage}`)
  }
  const data: Account = await response.json();
  return data;
}

export async function fetchTransactions(
  searchParams: URLSearchParams
):Promise<TransactionsResponse> {
  const params = new URLSearchParams(searchParams);
  const url = `http://127.0.0.1:3005/transactions?${searchParams}`;
  const response = await fetch(url,{
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching transactions: ${response.status}`);
  }
  const data: TransactionsResponse = await response.json();
  return data;
}

export async function updateTransaction(
  transaction_id: number,
  updates: TransactionUpdate
): Promise<Transaction> {
  const url = `http://127.0.0.1:3005/transactions/${transaction_id}`
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error updating transaction: ${errorMessage}`)
  }
  const data: Transaction = await response.json();
  return data;
}