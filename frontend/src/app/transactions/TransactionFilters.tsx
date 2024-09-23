import { Account, FilterItemType, User } from "@/app/lib/definitions";
import FilterSelector from "@/app/ui/shared/filters/FilterSelector";
import { usePathname, useRouter, useSearchParams } from "next/navigation";

type TransactionFiltersProps = {
  accounts: Account[];
  users: User[];
};

export default function TransactionFilters({
  accounts, users
}: TransactionFiltersProps) {

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleAccountClick = (id: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    let selectedAccounts = params.getAll('accounts[]');
    if (id === "0") {
      // if the value is 0, All was selected, so remove filter.
      params.delete('accounts[]');
    } else {
      // Add value to selected accounts.
      if (!selectedAccounts.includes(id)) {
        params.append('accounts[]', id);
      } else {
        // Remove value from selected accounts.
        selectedAccounts = selectedAccounts
          .filter(account => account !== id);
        params.delete('accounts[]');
        selectedAccounts.forEach(account => {
          params.append('accounts[]', account);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  const handleUserClick = (id: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);

    // Reset pagination to page 1 since users are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    let selectedUsers = params.getAll('users[]');
    if (id === "0") {
      // if the value is 0, All was selected, so remove filter.
      params.delete('users[]');
    } else {
      // Add value to selected users.
      if (!selectedUsers.includes(id)) {
        params.append('users[]', id);
      } else {
        // Remove value from selected users.
        selectedUsers = selectedUsers
          .filter(item => item !== id);
        params.delete('users[]');
        selectedUsers.forEach(user => {
          params.append('users[]', user);
        });
      }
    }
    replace(`${pathname}?${params.toString()}`)
  };

  // Get the selected accounts from the URL
  const selectedAccounts = searchParams.getAll('accounts[]');

  // Get the selected items from the URL
  const selectedUsers = searchParams.getAll('users[]');

  const accountItems: FilterItemType[] = accounts.map((account) => {
    const label = account.bankName ? `${account.bankName} ${account.name}` : account.name;
    const user = users.find(user => account.userId === user.id);

    return {
      id: account.id.toString(),
      label: label,
      sublabel: user?.name || ''
    }
  });

  const userItems: FilterItemType[] = users.map((user) => {
    return {
      id: user.id.toString(),
      label: user.name,
      sublabel: null
    }
  });

  return (
    <div className="flex flex-col items-center h-full w-full">
      <span className="text-xl">Filters</span>
      <FilterSelector
        title="Users"
        items={userItems}
        selectedItems={selectedUsers}
        onItemClick={handleUserClick}
      />
      <FilterSelector
        title="Accounts"
        items={accountItems}
        selectedItems={selectedAccounts}
        onItemClick={handleAccountClick}
      />
    </div>
  )
}