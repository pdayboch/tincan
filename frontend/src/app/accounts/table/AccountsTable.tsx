import { Account, AccountUpdate, SupportedAccount, User } from "@/app/lib/definitions";
import AddAccount from "../AddAccount";
import AccountSubRow from "./AccountSubRow";
import { createAccount, deleteAccount, updateAccount } from "@/app/lib/data";

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

  const handleAddAccount = async (
    accountProvider: SupportedAccount,
    userId: number,
    statementDirectory: string
  ): Promise<boolean> => {
    try {
      const createdAccount = await createAccount(
        accountProvider.accountProvider,
        userId,
        statementDirectory
      );
      const updatedAccounts = [...accounts, createdAccount];
      setAccounts(updatedAccounts);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error adding account ${error.message}`);
      } else {
        console.log('Error adding account: An unknown error occurred');
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

  const groupAndSortAccounts = (): GroupedAccounts[] => {
    // Filter out cash accounts
    const filteredAccounts = accounts.filter(account => account.name !== "Cash");

    const grouped: { [bankName: string]: { [userId: number]: Account[] } } = {};

    // Group accounts by bankName and userId
    filteredAccounts.forEach(account => {
      if (!grouped[account.bankName]) {
        grouped[account.bankName] = {};
      }

      if (!grouped[account.bankName][account.userId]) {
        grouped[account.bankName][account.userId] = [];
      }
      grouped[account.bankName][account.userId].push(account);
    })

    // Convert the grouped object to an array
    const result: GroupedAccounts[] = [];
    Object.keys(grouped).forEach(bankName => {
      Object.keys(grouped[bankName]).forEach(userId => {
        const userIdInt = parseInt(userId, 10)
        result.push({
          bankName,
          userId: userIdInt,
          accounts: grouped[bankName][userIdInt]
        });
      });
    });

    // Sort the result array by bankName and then by userId
    result.sort((a, b) => {
      if (a.bankName < b.bankName) return -1;
      if (a.bankName > b.bankName) return 1;
      if (a.userId < b.userId) return -1;
      if (a.userId > b.userId) return 1;
      return 0
    });

    return result;
  }

  const groupedAccounts = groupAndSortAccounts();
  const shouldDisplayUser = users.length > 1;

  return (
    <div className="w-full">
      {/* Add account top section */}
      <div className="flex justify-center my-4">
        <AddAccount
          users={users}
          onAddAccount={handleAddAccount}
        />
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-lg bg-gray-50 p-2">
        <table className="w-full text-gray-900">
          <thead className="rounded-lg text-left text-md font-normal">
            <tr>
              <th className="px-4 py-2 text-left font-medium">Bank</th>
              <th className="px-4 py-2 text-left font-medium">Accounts</th>
            </tr>
          </thead>

          <tbody>
            {groupedAccounts.map((bankAndUser, index) => {
              const user = shouldDisplayUser ? (users.find(user => user.id === bankAndUser.userId) || null) : null;

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
    </div>
  );
}