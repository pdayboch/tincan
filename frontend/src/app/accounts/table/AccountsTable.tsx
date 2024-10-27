import { Account, AccountUpdate, User } from "@/lib/definitions";
import AccountSubRow from "./AccountSubRow";
import { useEffect, useState } from "react";
import { deleteAccount, updateAccount } from "@/lib/api/account-api";

type AccountsTableProps = {
  accounts: Account[];
  users: User[];
  setAccounts: React.Dispatch<React.SetStateAction<Account[]>>;
}

type GroupedAccounts = {
  bankName: string,
  userId: number,
  accounts: Account[]
}

export default function AccountsTable({
  accounts,
  users,
  setAccounts
}: AccountsTableProps) {
  const [groupedAccounts, setGroupedAccounts] = useState<GroupedAccounts[]>([]);

  useEffect(() => {
    const groupAndSortAccounts = (): GroupedAccounts[] => {
      const filteredAccounts = accounts.filter(account => account.name !== "Cash");
      const groupedAccounts = groupAccountsByBankAndUser(filteredAccounts);
      const result = convertGroupedToArray(groupedAccounts);

      // Sort the result array by bankName and then by userId
      result.sort((a, b) => {
        if (a.bankName < b.bankName) return -1;
        if (a.bankName > b.bankName) return 1;
        if (a.userId < b.userId) return -1;
        if (a.userId > b.userId) return 1;
        return 0;
      });

      return result;
    };

    setGroupedAccounts(groupAndSortAccounts());
  }, [accounts])

  const updateAccountInState = (updatedAccount: Account) => {
    const updatedAccounts = accounts.map((account) => {
      if (account.id === updatedAccount.id) {
        return updatedAccount;
      }
      return account
    });

    setAccounts(updatedAccounts);
  }

  const handleUpdateAccount = async (
    accountId: number,
    data: AccountUpdate
  ): Promise<boolean> => {
    try {
      const updatedAccount = await updateAccount(
        accountId,
        data
      )
      updateAccountInState(updatedAccount)
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error updating account data: ${error.message}`);
      } else {
        console.log('Error updating account: An unknown error occurred');
      }
      return false;
    }
  };

  const handleDeleteAccount = async (accountId: number): Promise<boolean> => {
    try {
      const success = await deleteAccount(accountId)
      if (success) {
        const updatedAccounts = accounts.filter(account => account.id != accountId);
        setAccounts(updatedAccounts);
      }
      return success;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error deleting account data: ${error.message}`);
      } else {
        console.log('Error deleting account: An unknown error occurred');
      }
      return false;
    }
  };

  type GroupedAccountsMap = {
    [bankName: string]: { [userId: number]: Account[] }
  };

  // Takes the accounts array and groups them by bankName and userId.
  // example return { Chase: { 2: [Account1] } } }
  const groupAccountsByBankAndUser = (accounts: Account[]): GroupedAccountsMap => {
    const grouped: { [bankName: string]: { [userId: number]: Account[] } } = {};

    accounts.forEach(account => {
      if (!grouped[account.bankName]) {
        grouped[account.bankName] = {};
      }

      if (!grouped[account.bankName][account.user.id]) {
        grouped[account.bankName][account.user.id] = [];
      }
      grouped[account.bankName][account.user.id].push(account);
    });

    return grouped;
  };

  // Sorts an array of accounts by their name property
  const sortAccountsByName = (accounts: Account[]): Account[] => {
    return accounts.sort((a, b) => a.name.localeCompare(b.name));
  };

  // Converts a grouped accounts object into an array of GroupedAccounts
  // while also sorting the accounts within each group
  const convertGroupedToArray = (
    grouped: { [bankName: string]: { [userId: number]: Account[] } }
  ): GroupedAccounts[] => {
    const result: GroupedAccounts[] = [];

    Object.keys(grouped).forEach(bankName => {
      Object.keys(grouped[bankName]).forEach(userId => {
        const userIdInt = parseInt(userId, 10);
        // Sort the accounts by account name before pushing to result
        const sortedAccounts = sortAccountsByName(grouped[bankName][userIdInt]);

        result.push({
          bankName,
          userId: userIdInt,
          accounts: sortedAccounts
        });
      });
    });

    return result;
  };

  const shouldDisplayUser = users.length > 1;

  return (
    <div className="w-full overflow-x-auto rounded-lg bg-gray-50 p-2">
      <table className="w-full text-gray-900">
        <thead className="rounded-lg text-left text-md font-normal">
          <tr>
            <th className="px-4 py-2 text-left font-medium">Bank</th>
            <th className="px-4 py-2 text-left font-medium">Accounts</th>
          </tr>
        </thead>

        <tbody>
          {groupedAccounts.map((bankAndUser) => {
            const user = shouldDisplayUser ?
              (users.find(user => user.id === bankAndUser.userId) || null) :
              null;

            return (
              <tr
                key={`${bankAndUser.bankName}${bankAndUser.userId}`}
                className="bg-white w-full border-b text-sm \
                    last-of-type:border-none \
                    [&:first-child>td:first-child]:rounded-tl-lg \
                    [&:first-child>td:last-child]:rounded-tr-lg \
                    [&:last-child>td:first-child]:rounded-bl-lg \
                    [&:last-child>td:last-child]:rounded-br-lg"
              >
                <td className="px-4 py-2 border-b border-gray-300 align-top">
                  <div>
                    {bankAndUser.bankName}
                    {user && (
                      <div className="text-md text-gray-500">
                        {user.name}
                      </div>
                    )}
                  </div>
                </td>
                <td className="px-4 py-2 border-b border-gray-300">
                  <div className="text-md">
                    {bankAndUser.accounts.map(account => (
                      <AccountSubRow
                        key={account.id}
                        account={account}
                        onUpdateAccount={handleUpdateAccount}
                        onDeleteAccount={handleDeleteAccount}
                      />
                    ))}
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}