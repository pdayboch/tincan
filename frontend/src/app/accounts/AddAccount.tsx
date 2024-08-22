import Image from 'next/image';
import React, { useState, useEffect } from 'react';
import { PlusIcon } from "@heroicons/react/16/solid";
import { SupportedAccount, User } from '../lib/definitions';
import { fetchSupportedAccounts } from '../lib/data';

interface AddAccountProps {
  users: User[];
  onAddAccount: (
    accountProvider: SupportedAccount,
    userId: number,
    statementDirectory: string,
  ) => void;
};

export default function AddAccount({
  users,
  onAddAccount
}: AddAccountProps) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [supportedAccounts, setSupportedAccounts] = useState<SupportedAccount[]>([]);
  const [filteredAccounts, setFilteredAccounts] = useState<SupportedAccount[]>([]);
  const [selectedAccount, setSelectedAccount] = useState<SupportedAccount | null>(null);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [statementDirectory, setStatementDirectory] = useState<string>("");
  const [searchQuery, setSearchQuery] = useState<string>("");

  // Fetch Supported Accounts on component load.
  useEffect(() => {
    fetchSupportedAccounts()
      .then(data => {
        setSupportedAccounts(data);
        setFilteredAccounts(data);
      })
      .catch(error => {
        console.error(error);
        setSupportedAccounts([]);
        setFilteredAccounts([]);
      });
  }, []);

  const handleButtonClick = () => {
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    handleBackButtonClick(); // reset the modal state
    setSearchQuery(""); // reset the seach query
    setFilteredAccounts(supportedAccounts);
    setIsModalOpen(false);
  };

  const handleAccountSelect = (account: SupportedAccount) => {
    setSelectedAccount(account);
  };

  const handleBackButtonClick = () => {
    setSelectedAccount(null);
    setSelectedUserId(null);
    setStatementDirectory("");
  }

  const handleAddAccount = () => {
    if (selectedAccount && selectedUserId) {
      onAddAccount(
        selectedAccount,
        selectedUserId,
        statementDirectory
      );
      handleCloseModal();
    }
  };

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value.toLowerCase();
    setSearchQuery(query);
    const filtered = supportedAccounts.filter(account =>
      `${account.bankName} ${account.accountName}`.toLowerCase().includes(query)
    );
    setFilteredAccounts(filtered);
  };

  const handleClearSearch = () => {
    setSearchQuery("");
    setFilteredAccounts(supportedAccounts);
  }

  const getImageUrl = (accountPovider: string) => {
    return `/account_providers/${accountPovider}.png`;
  }

  return (
    <div>
      {/* Add Button */}
      <div
        className="flex flex-none items-center justify-center \
        h-10 w-64 \
        rounded-lg cursor-pointer \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner
        border"
        onClick={handleButtonClick}
      >
        <PlusIcon className="h-5 w-5" />
        <span className="text-m">Add Account</span>
      </div>
      {/* Add Account Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex justify-center items-center">
          <div className="bg-white p-4 rounded shadow-lg flex-none w-[700px] h-[700px] relative">
            {/* X (close) button */}
            <button
              onClick={handleCloseModal}
              className="absolute top-2 right-2 text-gray-500 hover:text-gray-700 text-xl"
            >&times;</button>
            {!selectedAccount ? (
              // Add account first screen - select provider
              <>
                <p>Select account</p>
                <div className="flex my-4">
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={handleSearchChange}
                    placeholder="Search accounts"
                    className="p-2 border rounded w-full"
                  />
                  <button
                    onClick={handleClearSearch}
                    className="ml-2 p-2 rounded"
                  >
                    Clear
                  </button>
                </div>
                <div className="grid grid-cols-3 gap-4 overflow-y-auto h-96">
                  {filteredAccounts.map((account) => (
                    <div
                      key={account.accountProvider}
                      className="fex flex-col items-center cursor-pointer"
                      onClick={() => handleAccountSelect(account)}
                    >
                      <div className="relative">
                        <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center">
                          <Image
                            src={getImageUrl(account.accountProvider)}
                            width={96}
                            height={96}
                            alt={`${account.bankName} ${account.accountName}`}
                            className="object-contain rounded-lg"
                            style={{ height: '96px', width: 'auto' }}
                          />
                        </div>
                      </div>
                      <span className="mt-2 text-center">
                        {account.bankName}<br />{account.accountName}
                      </span>
                    </div>
                  ))}
                </div>
              </>
            ) : (
              // Add account second screen - details
              <div>
                <h2 className="text-2xl mb-4">Add Account Details</h2>
                <p className="text-xl">{selectedAccount.bankName || ""} {selectedAccount.accountName}</p>
                <label htmlFor="user-select">User:</label>
                <select
                  id="user-select"
                  value={selectedUserId ? selectedUserId : ''}
                  onChange={(e) => {
                    const userId = Number(e.target.value);
                    setSelectedUserId(userId);
                  }}
                >
                  <option value="" disabled>Select a user</option>
                  {users.map((user) => (
                    <option key={user.id} value={user.id}>
                      {user.name}
                    </option>
                  ))}
                </select>
                <div className="mt-20 flex justify-end">
                  <button
                    onClick={handleBackButtonClick}
                    className="bg-red-500 text-white px-4 py-2 rounded mr-2"
                  >
                    Back
                  </button>
                  <button
                    onClick={handleAddAccount}
                    disabled={!selectedUserId}
                    className="bg-gray-500 text-white px-4 py-2 rounded"
                  >
                    Add Account
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}