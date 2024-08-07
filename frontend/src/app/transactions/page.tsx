"use client"
import { useState, useEffect } from 'react'
import Search from './table/Search';
import { CreateTransaction } from './table/buttons';
import TransactionsTable from './table/TransactionsTable';
import FilterBar from './filter-bar/FilterBar';
import { Account, Category, Transaction, TransactionMetaData, User } from '../lib/definitions';
import { fetchAccounts, fetchCategories, fetchTransactions, fetchUsers } from '../lib/data';
import { useSearchParams } from 'next/navigation';

export default function Page() {
  const [
    isLoadingTransactions,
    setLoadingTransactions
  ] = useState<boolean>(true)

  const [
    transactions,
    setTransactions
  ] = useState<Transaction[]>([]);

  const [
    transactionMetaData,
    setTransactionMetaData
  ] = useState<TransactionMetaData>({
    totalCount: 0,
    filteredCount: 0,
    prevPage: null,
    nextPage: null
  })

  const [
    isLoadingCategories,
    setLoadingCategories
  ] = useState<boolean>(true)

  const [
    categories,
    setCategories
  ] = useState<Category[]>([]);

  const[
    isLoadingAccounts,
    setLoadingAccounts
  ] = useState<boolean>(true);

  const [
    accounts,
    setAccounts
  ] = useState<Account[]>([]);

  const[
    isLoadingUsers,
    setLoadingUsers
  ] = useState<boolean>(true);

  const [
    users,
    setUsers
  ] = useState<User[]>([]);

  const searchParams = useSearchParams();

  // fetch and store all users
  useEffect(() => {
    setLoadingUsers(true);
    fetchUsers()
      .then(data => {
        setUsers(data);
        setLoadingUsers(false);
      })
      .catch(error => {
        console.error(error);
        setUsers([]);
        setLoadingUsers(false);
      });
  }, []);

  // fetch and store all accounts
  useEffect(() => {
    setLoadingAccounts(true);
    fetchAccounts()
      .then(data => {
        setAccounts(data);
        setLoadingAccounts(false);
      })
      .catch(error => {
        console.error(error);
        setAccounts([]);
        setLoadingAccounts(false);
      });
  }, []);

  // fetch and store all categories
  useEffect(() => {
    setLoadingCategories(true);
    fetchCategories()
      .then(data => {
        setCategories(data.categories);
        setLoadingCategories(false);
      })
      .catch(error => {
        console.error(error);
        setCategories([]);
        setLoadingCategories(false);
      });
  }, []);

  // fetch and store filtered transactions
  useEffect(() => {
    setLoadingTransactions(true);
    fetchTransactions(searchParams)
    .then(data => {
      setTransactions(data.transactions);
      setTransactionMetaData({
        totalCount: data.meta.totalCount,
        filteredCount: data.meta.filteredCount,
        prevPage: data.meta.prevPage,
        nextPage: data.meta.nextPage
    });
      setLoadingTransactions(false);
    })
    .catch(error => {
      console.error(error);
      setTransactions([]);
      setLoadingTransactions(false);
    });
  }, [searchParams]);

  return (
    <div className="flex m-4">
      {/* Left panel */}
      <div className="hidden lg:block flex-none w-40">
        <p>Accounts</p>
        <div className="flex items-center justify-between gap-2">
          <FilterBar accounts={accounts} users={users} />
        </div>
        <p>Users</p>
      </div>

      {/* Center content */}
      <div className="flex-grow flex flex-col w-full lg:w-[600px] mx-auto">
       {/* FilterBar, Search, and CreateTransaction in one row */}
        <div className="flex items-center justify-between gap-2 my-3 h-10">
          {/* Show FilterBar only on "sm" screens */}
          <div className="lg:hidden h-full">
            <FilterBar accounts={accounts} users={users} />
          </div>
          {/* Search and CreateTransaction always visible */}
          <Search placeholder="Search transactions..." />
          <CreateTransaction />
        </div>
        <TransactionsTable
          transactions={transactions}
          transactionMetaData={transactionMetaData}
          categories={categories}
          setTransactions={setTransactions}
        />
      </div>

      {/* Right panel */}
      <div className="flex-auto"></div>
    </div>
  );
}