"use client"
import { useState, useEffect } from 'react'
import { useSearchParams } from 'next/navigation';
import Search from './Search';
import { CreateTransaction } from './buttons';
import TransactionsTable from './table/TransactionsTable';
import Filters from './TransactionFilters';
import { Account, Category, Transaction, TransactionMetaData, User } from '../lib/definitions';
import { fetchAccounts, fetchCategories, fetchTransactions, fetchUsers } from '../lib/data';

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
    <div className="flex">
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <Filters accounts={accounts} users={users} />
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col w-full mx-auto">
        <div className="flex items-center justify-between gap-2 my-3 h-10">
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
    </div>
  );
}