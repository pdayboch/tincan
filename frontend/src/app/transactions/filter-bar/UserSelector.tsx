import React, { useState } from 'react';
import DropdownItem from './Dropdown/DropdownItem';
import { User } from '@/app/lib/definitions';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';

type UserSelectorProps = {
  users: User[];
};

export default function UserSelector({ users }: UserSelectorProps) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleUserClick = (value: number) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since users are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    let selectedUsers = params.getAll('users');
    if (value === 0) {
      // if the value is 0, All was selected, so remove filter.
      params.delete('users');
    } else {
      // Add value to selected users.
      if (!selectedUsers.includes(value.toString())){
        params.append('users', value.toString());
      } else {
        // Remove value from selected users.
        selectedUsers = selectedUsers
          .filter(user => user !== value.toString());
        params.delete('users');
        selectedUsers.forEach(user => {
          params.append('users', user);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the selected users from the URL
  const selectedUsers = searchParams.getAll('users');

  // State to control the visibility of the dropdown
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // Toggle the dropdown open/close
  const toggleDropdown = () => setIsDropdownOpen(!isDropdownOpen);

  return (
    <div className="relative h-full">
      <button
        type="button"
        className="border border-gray-300 bg-white hover:bg-blue-100 rounded w-full h-full py-0 px-2"
        onClick={toggleDropdown}
      >
        Users
      </button>

      {isDropdownOpen && (
        <div className="absolute z-9 mt-1 w-64 h-auto max-h-96 overflow-y-auto rounded-md bg-white shadow-lg">
          <hr className="my-1"/>
          <DropdownItem
            key={0}
            title="All"
            subtitle={users.length.toString()}
            isSelected={selectedUsers.length === 0}
            onClick={() => handleUserClick(0)}
          />
          <hr className="my-1"/>
          {users.map((user) => {
            return(
              <DropdownItem
                key={user.id}
                title={user.name}
                subtitle={""}
                isSelected={selectedUsers.includes(user.id.toString())}
                onClick={() => handleUserClick(user.id)}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}