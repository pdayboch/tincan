import React, { useState } from 'react';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import { Account } from '@/app/lib/definitions';

type AccountSelectorProps = {
  accounts: Account[];
};

function formatAccount(account: Account) {
  return (
    <div className="flex text-md">
      {account.bankName + " " + account.name}
      <span className="text-sm text-gray-500 ml-2 mt-1">
        {account.user}
      </span>
    </div>
  );
}

export default function AccountSelector({ accounts }: AccountSelectorProps) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleSelectionChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    // Get the value of the checkbox that triggered the event
    const checkboxValue = event.target.value;
    // Determine if the checkbox was checked or unchecked
    const isChecked = event.target.checked;

    // Clone the current search params
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.set('page', '1');

    // Get the current array of filtered accounts
    let filteredAccounts = params.getAll('filteredAccounts');

    if (!isChecked) {
      // If the account was unchecked, add it to the filteredAccounts array
      if (!filteredAccounts.includes(checkboxValue)) {
        filteredAccounts.push(checkboxValue);
      }
    } else {
      // If the account was checked, remove it from the filteredAccounts array
      filteredAccounts = filteredAccounts
        .filter((account) => account !== checkboxValue)
    }

    // Clear the existing 'filteredAccounts' query parameters
    params.delete('filteredAccounts');
    // Re-add the updated list of account IDs to the query parameters
    filteredAccounts.forEach((account) => {
      params.append('filteredAccounts', account);
    });

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the current filtered accounts from the URL
  const filteredAccounts = searchParams.getAll('filteredAccounts');
  const checkedAccounts = accounts
    .map((account) => account.id.toString())
    .filter((account) => !filteredAccounts.includes(account))

  // State to control the visibility of the dropdown
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // Toggle the dropdown open/close
  const toggleDropdown = () => setIsDropdownOpen(!isDropdownOpen);

  return (
    <div className="relative">
      <button
        type="button"
        className="border border-gray-300 bg-white p-2 rounded"
        onClick={toggleDropdown}
      >
        Select Accounts
      </button>

      {isDropdownOpen && (
        <div className="absolute z-9 mt-1 w-64 rounded-md bg-white shadow-lg">
          {accounts.map((account) => {
            const isChecked = !filteredAccounts
              .includes(account.id.toString());
            return(
              <label key={account.id} className="flex items-center p-2">
                <input
                  type="checkbox"
                  value={account.id}
                  checked={isChecked}
                  onChange={handleSelectionChange}
                />
                <span className="ml-2">{formatAccount(account)}</span>
              </label>
            );
          })}
        </div>
      )}
    </div>
  );
}