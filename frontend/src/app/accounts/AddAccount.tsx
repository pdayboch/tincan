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
  const [selectedAccount, setSelectedAccount] = useState<SupportedAccount | null>(null);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [statementDirectory, setStatementDirectory] = useState<string>("");

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

  const handleButtonClick = () => {
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    handleBackButtonClick(); // reset the modal state
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

  const getImageUrl = (imageFilename: string) => {
    return `http://127.0.0.1:3005/${imageFilename}`;
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
        <span>Add Account</span>
      </div>
      {/* Add Account Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex justify-center items-center">
          <div className="bg-white p-4 rounded shadow-lg flex-none w-[700px] h-[700px] relative">
            {/* X (close) button */}
            <button
              onClick={handleCloseModal}
              className="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
            >&times;</button>
            {!selectedAccount ? (
              // Add account first screen - select provider
              <>
                <p>Select account</p>
                <div className="grid grid-cols-3 gap-4">
                  {supportedAccounts.map((account) => (
                    <div
                      key={account.accountProvider}
                      className="fex flex-col items-center cursor-pointer"
                      onClick={() => handleAccountSelect(account)}
                    >
                      <div className="relative">
                        <div className="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center">
                          <img
                            src={getImageUrl(account.imageFilename)}
                            alt={`${account.bankName} ${account.accountName}`}
                            className="w-24 h-24 object-contain rounded-lg"
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