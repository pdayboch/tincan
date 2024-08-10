'use client'
import React, { useEffect, useRef, useState } from 'react';
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

    let selectedUsers = params.getAll('users[]');
    if (value === 0) {
      // if the value is 0, All was selected, so remove filter.
      params.delete('users[]');
    } else {
      // Add value to selected users.
      if (!selectedUsers.includes(value.toString())){
        params.append('users[]', value.toString());
      } else {
        // Remove value from selected users.
        selectedUsers = selectedUsers
          .filter(user => user !== value.toString());
        params.delete('users[]');
        selectedUsers.forEach(user => {
          params.append('users[]', user);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the selected users from the URL
  const selectedUsers = searchParams.getAll('users[]');

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
    <div className="h-auto w-full my-1" ref={selectorRef}>
      <button
        type="button"
        className="w-full h-10 py-0 px-2 rounded \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner \
        border border-gray-300"
        onClick={toggleDropdown}
      >
        Users
      </button>

      {isDropdownOpen && (
        <div className="w-full h-auto mt-1 max-h-96 overflow-y-auto rounded-md bg-white shadow-lg">
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