import { Account } from "@/lib/definitions";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import Select, { MultiValue } from 'react-select';

interface AccountFilterProps {
  accounts: Account[];
}

type AccountOptionType = {
  id: number;
  value: number,
  label: string,
  userName: string;
};

export default function AccountFilter({
  accounts
}: AccountFilterProps) {
  const [selectedAccounts, setSelectedAccounts] = useState<AccountOptionType[]>([]);
  const accountOptions = accounts.map((account) => ({
    id: account.id,
    value: account.id,
    label: account.name,
    userName: account.user.name
  }));

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  useEffect(() => {
    const accountsParam = searchParams.getAll('accounts[]');
    const newSelectedAccounts = accountOptions.filter(options =>
      accountsParam.includes(String(options.value))
    );

    setSelectedAccounts(newSelectedAccounts);
  }, [searchParams]);


  const handleSelectionChange = (
    selectedOptions: MultiValue<AccountOptionType>
  ) => {
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    // Update accounts[] param
    if (selectedOptions.length > 0) {
      const selectedIds = selectedOptions.map(option =>
        String(option.value)
      );
      params.delete('accounts[]');
      selectedIds.forEach(id => params.append('accounts[]', id))
    } else {
      params.delete('accounts[]');
    }

    replace(`${pathname}?${params.toString()}`)
  };

  // Custom dropdown option formatting
  const formatOptionLabel = (
    option: AccountOptionType,
    { context }: { context: "menu" | "value" }
  ) => {
    if (context === "menu") {
      return (
        <div className="flex justify-between items-center">
          <span>{option.label}</span>
          <span className="text-sm text-gray-500">{option.userName}</span>
        </div>
      );
    }

    return `${option.label} - ${option.userName}`
  };

  return (
    <Select
      instanceId="account-filter-select"
      options={accountOptions}
      isMulti
      isSearchable
      placeholder="All Accounts"
      onChange={handleSelectionChange}
      value={selectedAccounts}
      formatOptionLabel={formatOptionLabel}
    />
  );
}