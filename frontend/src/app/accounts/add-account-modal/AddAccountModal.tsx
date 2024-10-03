import React, { useState, useEffect } from 'react';
import { SupportedAccount, User } from '../../../lib/definitions';
import AccountPickerScreen from './screens/AccountPickerScreen';
import AccountDetailsScreen from './screens/AccountDetailsScreen';
import { fetchSupportedAccounts } from '@/lib/api/account-api';

interface AddAccountModalProps {
  users: User[];
  onAddAccount: (
    accountProvider: SupportedAccount,
    userId: number,
    statementDirectory: string,
  ) => void;
  onCloseModal: () => void;
};

export default function AddAccountModal({
  users,
  onAddAccount,
  onCloseModal
}: AddAccountModalProps) {
  const [supportedAccounts, setSupportedAccounts] = useState<SupportedAccount[]>([]);
  const [selectedAccount, setSelectedAccount] = useState<SupportedAccount | null>(null);
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Fetch Supported Accounts on component load.
  useEffect(() => {
    fetchSupportedAccounts()
      .then(data => {
        setSupportedAccounts(data);
      })
      .catch(error => {
        console.error(error);
        setSupportedAccounts([]);
      });
  }, []);

  const handleCloseModal = () => {
    setSelectedAccount(null);
    setSearchQuery('');
    onCloseModal();
  };

  const handleAccountSelect = (account: SupportedAccount) => {
    setSelectedAccount(account);
  };

  const handleAddAccount = (userId: number, statementDirectory: string) => {
    if (selectedAccount) {
      onAddAccount(
        selectedAccount,
        userId,
        statementDirectory
      );
      handleCloseModal();
    }
  };

  const handleBackButtonClick = () => {
    setSelectedAccount(null);
  };

  return (
    <div className='fixed inset-0 bg-gray-700 bg-opacity-50 \
                    flex justify-center items-center'
    >
      <div className='flex flex-col bg-white px-6 py-4 rounded-lg \
                      shadow-xl w-[700px] h-[700px] relative'
      >
        {/* X (close) button */}
        <button
          onClick={handleCloseModal}
          className='absolute top-2 right-2 px-4 py-1 text-xl rounded-full \
            text-gray-500 hover:text-gray-700 hover:bg-gray-200 transition-colors'
        >
          &times;
        </button>

        {!selectedAccount ? (
          <AccountPickerScreen
            supportedAccounts={supportedAccounts}
            searchQuery={searchQuery}
            setSearchQuery={setSearchQuery}
            onAccountSelect={handleAccountSelect}
          />
        ) : (
          <AccountDetailsScreen
            users={users}
            selectedAccount={selectedAccount}
            onAddAccount={handleAddAccount}
            onBackButtonClick={handleBackButtonClick}
          />
        )
        }
      </div >
    </div >
  );
}