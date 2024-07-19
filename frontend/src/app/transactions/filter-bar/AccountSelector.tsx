'use client'
import React, { useEffect, useRef, useState } from 'react';
import DropdownItem from './Dropdown/DropdownItem';
import { Account, User } from '@/app/lib/definitions';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';

type AccountSelectorProps = {
  accounts: Account[];
  users: User[]
};

export default function AccountSelector({ accounts, users }: AccountSelectorProps) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleAccountClick = (value: number) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    let selectedAccounts = params.getAll('accounts[]');
    if (value === 0) {
      // if the value is 0, All was selected, so remove filter.
      params.delete('accounts[]');
    } else {
      // Add value to selected accounts.
      if (!selectedAccounts.includes(value.toString())){
        params.append('accounts[]', value.toString());
      } else {
        // Remove value from selected accounts.
        selectedAccounts = selectedAccounts
          .filter(account => account !== value.toString());
        params.delete('accounts[]');
        selectedAccounts.forEach(account => {
          params.append('accounts[]', account);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the selected accounts from the URL
  const selectedAccounts = searchParams.getAll('accounts[]');

  // State to control the visibility of the dropdown
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // Toggle the dropdown open/close
  const toggleDropdown = () => setIsDropdownOpen(!isDropdownOpen);

  // Ref for the Selector component
  const selectorRef = useRef<HTMLDivElement>(null);

  // Event handler for closing the dropdown if clicked outside
  const handleClickOutside = (event: MouseEvent) => {
    if (selectorRef.current &&
        !selectorRef.current.contains(event.target as Node)) {
      setIsDropdownOpen(false);
    }
  }

  // Add event listener when the component mounts
  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      // Remove event listener when the component unmounts
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [])

  return (
    <div className="relative h-full" ref={selectorRef}>
      <button
        type="button"
        className="w-full h-full py-0 px-2 rounded \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner \
        border border-gray-300"
        onClick={toggleDropdown}
      >
        Accounts
      </button>

      {isDropdownOpen && (
        <div className="absolute z-9 mt-1 w-64 h-auto max-h-96 overflow-y-auto rounded-md bg-white shadow-lg">
          <hr className="my-1"/>
          <DropdownItem
            key={0}
            title="All"
            subtitle="5 accounts"
            isSelected={selectedAccounts.length === 0}
            onClick={() => handleAccountClick(0)}
          />
          <hr className="my-1"/>
          {accounts.map((account) => {
            const title = account.bank_name ? `${account.bank_name} ${account.name}` : account.name
            const user = users.find(user => account.user_id === user.id)
            return(
              <DropdownItem
                key={account.id}
                title={title}
                subtitle={user?.name || ''}
                isSelected={selectedAccounts.includes(account.id.toString())}
                onClick={() => handleAccountClick(account.id)}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}