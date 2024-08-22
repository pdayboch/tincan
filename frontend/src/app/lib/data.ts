import {
  CategoryResponse,
  TransactionsResponse,
  TransactionUpdate,
  Transaction,
  Account,
  User,
  AccountUpdate,
  SupportedAccount
} from "./definitions";

const getBaseApiUrl = () => {
  return process.env.NEXT_PUBLIC_API_BASE_URL || 'http://127.0.0.1:3005';
};

export async function fetchCategories(): Promise<CategoryResponse> {
  const url = `${getBaseApiUrl()}/categories`;
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
  const url = `${getBaseApiUrl()}/users`;
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
  const url = `${getBaseApiUrl()}/accounts`;
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
  const url = `${getBaseApiUrl()}/accounts/${accountId}`;
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

export async function createAccount(
  accountProvider: string,
  userId: number,
  statementDirectory: string
): Promise<Account> {
  const url = `${getBaseApiUrl()}/accounts`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      accountProvider: accountProvider,
      userId: userId,
      statementDirectory: statementDirectory
    })
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error Creating Account: ${errorMessage}`)
  }
  const data: Account = await response.json();
  return data;
}

export async function deleteAccount(
  accountId: number,
): Promise<boolean> {
  const url = `${getBaseApiUrl()}/accounts/${accountId}`;
  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json'
    },
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error deleting account: ${errorMessage}`)
  }
  return true;
}

export async function fetchSupportedAccounts(): Promise<SupportedAccount[]> {
  const url = `${getBaseApiUrl()}/accounts/supported`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });
  if (!response.ok) {
    throw new Error(`Error fetching supported accounts: ${response.status}`);
  }
  const data: SupportedAccount[] = await response.json();
  return data;
}

export async function fetchTransactions(
  searchParams: URLSearchParams
): Promise<TransactionsResponse> {
  const params = new URLSearchParams(searchParams);
  const url = `${getBaseApiUrl()}/transactions?${searchParams}`;
  const response = await fetch(url, {
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
  const url = `${getBaseApiUrl()}/transactions/${transaction_id}`;
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