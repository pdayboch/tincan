"use client"
import { useEffect, useState } from 'react';
import { Account, User } from '../lib/definitions';
import { fetchAccounts, fetchUsers } from '../lib/data';
import Filters from './AccountFilters';
import AccountsTable from './table/AccountsTable';

export default function Page() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoadingUsers, setIsLoadingUsers] = useState<boolean>(true)
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [isLoadingAccounts, setIsLoadingAccounts] = useState<boolean>(true)

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
        setAccounts(data);
        setIsLoadingAccounts(false);
      })
      .catch(error => {
        console.error(error);
        setAccounts([]);
        setIsLoadingAccounts(false);
      });
  }, []);

  return (
    <div className="flex">
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <Filters accounts={accounts} users={users} />
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col w-full mx-auto">
        <AccountsTable
        />
      </div>
    </div>
  );
}