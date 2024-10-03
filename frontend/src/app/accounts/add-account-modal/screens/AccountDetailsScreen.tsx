import React, { useState } from 'react';
import { ArrowLeftIcon, PlusCircleIcon } from '@heroicons/react/16/solid';
import clsx from 'clsx';
import { SupportedAccount, User } from '@/lib/definitions';

interface AccountDetailsScreenProps {
  users: User[];
  selectedAccount: SupportedAccount;
  onAddAccount: (userId: number, statementDirectory: string) => void;
  onBackButtonClick: () => void;
}

export default function AccountDetailsScreen({
  users,
  selectedAccount,
  onAddAccount,
  onBackButtonClick
}: AccountDetailsScreenProps) {
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [statementDirectory, setStatementDirectory] = useState<string>('');

  const handleAddAccount = () => {
    if (selectedUserId) {
      onAddAccount(selectedUserId, statementDirectory);
    }
  };

  const handleBackButtonClick = () => {
    setSelectedUserId(null);
    setStatementDirectory('');
    onBackButtonClick()
  }

  return (
    <>
      <h2 className='text-xl font-semibold mb-4 text-gray-800'>Add Account Details</h2>

      <p className='text-lg font-medium text-gray-700 mb-4'>
        {selectedAccount.bankName || ''} {selectedAccount.accountName}
      </p>

      <div className='mb-4'>
        <label
          htmlFor='user-select'
          className='block text-sm font-medium text-gray-700'
        >
          User:
        </label>
        <select
          id='user-select'
          value={selectedUserId ? selectedUserId : ''}
          onChange={(e) => {
            const userId = Number(e.target.value);
            setSelectedUserId(userId);
          }}
        >
          <option value='' disabled>Select a user</option>
          {users.map((user) => (
            <option key={user.id} value={user.id}>
              {user.name}
            </option>
          ))}
        </select>
      </div>

      <div className='mb-4'>
        <label
          htmlFor='statement-directory'
          className='block text-sm font-medium text-gray-700'
        >
          Statement Directory (optional):
        </label>
        <input
          type='text'
          id='statement-directory'
          value={statementDirectory}
          onChange={(e) => setStatementDirectory(e.target.value)}
          placeholder=''
          className='mt-1 block w-3/4 py-2 px-3 border border-gray-300 \
                  rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 \
                  focus:border-indigo-500 sm:text-sm'
        />
      </div>

      <div className='mt-6 flex justify-end'>
        <button
          onClick={handleBackButtonClick}
          className='bg-red-400 hover:bg-red-500 text-white px-4 py-2 \
                  rounded-lg mr-3 shadow-sm flex items-center space-x-2 \
                  transition duration-300 ease-in-out'
        >
          <ArrowLeftIcon className='h-5 w-5' />
          <span>Back</span>
        </button>

        <button
          onClick={handleAddAccount}
          disabled={!selectedUserId}
          className={clsx(
            'px-4 py-2 rounded-lg shadow-sm flex items-center space-x-2',
            'transition duration-300 ease-in-out',
            selectedUserId ?
              'bg-theme-lgt-green hover:bg-theme-drk-green active:bg-theme-pressed-green' :
              'bg-gray-300 text-gray-500 cursor-not-allowed'
          )}
        >
          <PlusCircleIcon className='h-5 w-5' />
          <span>Add Account</span>
        </button>
      </div>
    </>
  );
}