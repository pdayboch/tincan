import { Account, User } from "@/app/lib/definitions";
import AddAccount from "../AddAccount";
import BankRow from "./BankRow";

type AccountsTableProps = {
  accounts: Account[];
  users: User[];
}

type GroupedAccounts = {
  bankName: string,
  userId: number,
  accounts: Account[]
}

export default function AccountsTable({
  accounts,
  users
}: AccountsTableProps) {

  const groupAndSortAccounts = (): GroupedAccounts[] => {
    // Filter out cash accounts
    const filteredAccounts = accounts.filter(account => account.name !== "Cash");

    const grouped: {[bankName: string]: { [userId: number]: Account[] } } = {};

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
    result.sort((a,b) => {
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
      <div className="flex justify-center my-4">
        <AddAccount/>
      </div>

      <hr className="my-1"/>

      <div className="grid grid-cols-2 gap-4 mt-4">
        <span className="text-xl">Bank</span>
        <span className="text-xl">Accounts</span>
      </div>

      <hr className="my-1"/>

      {groupedAccounts.map((bankAndUser, index) => {
        const user = shouldDisplayUser ? (users.find(user => user.id === bankAndUser.userId) || null) : null;

        return (
          <>
            <BankRow
              key={`${bankAndUser.bankName}${bankAndUser.userId}`}
              bankName={bankAndUser.bankName}
              accounts={bankAndUser.accounts}
              user={user}
            />
            {index < groupedAccounts.length - 1 && <hr className="my-4" />}
          </>
        );
      })}
    </div>
  );
}