import { getBaseApiUrl } from "@/utils/api-utils";
import { Transaction, TransactionsResponse, TransactionUpdate } from "../definitions";

export async function fetchTransactions(
  searchParams: URLSearchParams
): Promise<TransactionsResponse> {
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