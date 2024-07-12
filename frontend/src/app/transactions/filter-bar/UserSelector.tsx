import React, { useState } from 'react';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import { User } from '@/app/lib/definitions';

type UserSelectorProps = {
  users: User[];
};

export default function UserSelector({users}: UserSelectorProps) {
  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleSelectionChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    // Get the value of the checkbox that triggered the event
    const userValue = event.target.value;
    // Determine if the checkbox was checked or unchecked
    const isChecked = event.target.checked;

    // Clone the current search params
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.set('page', '1');

    // Get the current array of selected account IDs
    let selectedUserIds = params.getAll('users');

    if (isChecked) {
      // Add the account ID to the array if it's not already present
      if (!selectedUserIds.includes(userValue)) {
        selectedUserIds.push(userValue);
      }
    } else {
      // Remove the account ID from the array
      selectedUserIds = selectedUserIds.filter((id) => id !== userValue)
    }

    // Clear the existing 'accounts' query parameters
    params.delete('users');
    // Re-add the updated list of account IDs to the query parameters
    selectedUserIds.forEach((id) => {
      params.append('users', id);
    });

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the current selected accounts from the URL
  const selectedUserIds = searchParams.getAll('users');

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
        Select Users
      </button>

      {isDropdownOpen && (
        <div className="absolute z-10 mt-1 w-full rounded-md bg-white shadow-lg">
          {users.map((user) =>{
            const isChecked = selectedUserIds.includes(user.id.toString());
            return(
              <label key={user.id} className="flex items-center p-2">
                <input
                  type="checkbox"
                  value={user.id}
                  checked={isChecked}
                  onChange={handleSelectionChange}
                />
                <span className="ml-2">{user.name}</span>
              </label>
            );
          })}
        </div>
      )}
    </div>
  );
}