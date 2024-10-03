import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Account, User } from "@/lib/definitions";
import FilterSelector from "@/components/filters/FilterSelector";
import { FilterItemType } from "../../components/filters/FilterItem";

type AccountFiltersProps = {
  accounts: Account[];
  users: User[];
};

export default function AccountFilters({
  accounts, users
}: AccountFiltersProps) {

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleAccountTypeClick = (type: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);

    let selectedAccountTypes = params.getAll('accountTypes[]');
    if (type === "0") {
      params.delete('accountTypes[]');
    } else {
      // Add value to selected accounts.
      if (!selectedAccountTypes.includes(type)) {
        params.append('accountTypes[]', type);
      } else {
        // Remove value from selected accounts.
        selectedAccountTypes = selectedAccountTypes
          .filter(accountType => accountType !== type);
        params.delete('accountTypes[]');
        selectedAccountTypes.forEach(accountType => {
          params.append('accountTypes[]', accountType);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  const handleUserClick = (id: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);

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
  const selectedAccountTypes = searchParams.getAll('accountTypes[]');

  // Get the selected items from the URL
  const selectedUsers = searchParams.getAll('users[]');

  const accountTypeItems = (): FilterItemType[] => {
    const accountTypeMap: { [key: string]: number } = {};
    accounts.forEach(account => {
      if (accountTypeMap[account.accountType]) {
        accountTypeMap[account.accountType]++;
      } else {
        accountTypeMap[account.accountType] = 1;
      }
    });

    return Object.keys(accountTypeMap).map(accountType => ({
      id: accountType,
      label: accountType,
      sublabel: `${accountTypeMap[accountType]} accounts`
    }));
  };

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
        title="Account Type"
        items={accountTypeItems()}
        selectedItems={selectedAccountTypes}
        onItemClick={handleAccountTypeClick}
      />
    </div>
  )
}