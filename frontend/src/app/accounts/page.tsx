"use client"
import { Suspense, useEffect, useState } from 'react';
import { PlusIcon } from "@heroicons/react/24/solid";
import { Account, SupportedAccount, User } from '../../lib/definitions';
import Filters from './AccountFilters';
import AccountsTable from './table/AccountsTable';
import { Inter } from "next/font/google";
import clsx from 'clsx';
import AddAccountModal from './add-account-modal/AddAccountModal';
import { fetchUsers } from '@/lib/api/user-api';
import { createAccount, fetchAccounts } from '@/lib/api/account-api';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

function AccountsContent() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoadingUsers, setIsLoadingUsers] = useState<boolean>(true)
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [isLoadingAccounts, setIsLoadingAccounts] = useState<boolean>(true)
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // fetch and store all users
  useEffect(() => {
    setIsLoadingUsers(true);
    fetchUsers()
      .then(data => {
        setUsers(data);
        setIsLoadingUsers(false);
      })
      .catch(error => {
        console.error(error);
        setUsers([]);
        setIsLoadingUsers(false);
      });
  }, []);

  // fetch and store all accounts
  useEffect(() => {
    setIsLoadingAccounts(true);
    fetchAccounts()
      .then(data => {
        // Filter out accounts named "Cash" or without an accountType
        const filteredAccounts = data.filter(
          (account: Account) => account.name !== "Cash" && account.accountType
        );
        setAccounts(filteredAccounts);
        setIsLoadingAccounts(false);
      })
      .catch(error => {
        console.error(error);
        setAccounts([]);
        setIsLoadingAccounts(false);
      });
  }, []);

  const handleAddAccountClick = () => {
    setIsAddModalOpen(true);
  };

  const handleAddAccount = async (
    accountProvider: SupportedAccount,
    userId: number,
    statementDirectory: string
  ): Promise<boolean> => {
    try {
      const createdAccount = await createAccount(
        accountProvider.accountProvider,
        userId,
        statementDirectory
      );
      const updatedAccounts = [...accounts, createdAccount];
      setAccounts(updatedAccounts);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error adding account ${error.message}`);
      } else {
        console.log('Error adding account: An unknown error occurred');
      }
      return false;
    }
  };

  const handleCloseModal = () => {
    setIsAddModalOpen(false);
  };

  return (
    <div className={clsx("flex", font.className)}>
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <Filters accounts={accounts} users={users} />
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col items-center w-full mx-auto max-w-4xl">
        <button
          className="flex flex-none items-center justify-center h-10 w-64 mb-5 \
                    rounded-lg cursor-pointer border bg-theme-lgt-green \
                    hover:bg-theme-drk-green active:bg-theme-pressed-green \
                    active:scale-95 active:shadow-inner"
          onClick={handleAddAccountClick}
        >
          <PlusIcon className="h-5 w-5" />
          <span className="text-m">Add Account</span>
        </button>

        {isAddModalOpen && (
          <AddAccountModal
            users={users}
            onAddAccount={handleAddAccount}
            onCloseModal={handleCloseModal}
          />
        )}

        <AccountsTable
          accounts={accounts}
          users={users}
          setAccounts={setAccounts}
        />
      </div>
    </div>
  );
}

export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <AccountsContent />
    </Suspense>
  );
}