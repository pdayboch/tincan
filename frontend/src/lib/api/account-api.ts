import { getBaseApiUrl } from "@/utils/api-utils";
import { Account, AccountUpdate, SupportedAccount } from "../definitions";

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