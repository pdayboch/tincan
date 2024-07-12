"use client"
import { useState, useEffect } from 'react'
import Search from './table/Search';
import { CreateTransaction } from './table/buttons';
import TransactionsTable from './table/TransactionsTable';
import FilterBar from './filter-bar/FilterBar';
import { Account, Category, Transaction, User } from '../lib/definitions';
import { fetchCategories, fetchTransactions } from '../lib/data';

const accounts: Account[] = [
  { id: 1, bankName: "Chase", name: 'Freedom', accountType: "credit card", user: "Phil" }
]

const users: User[] = [
  { id: 1, name: 'Phil' }
]

export default function Page({
  searchParams,
}:{
  searchParams?: {
    query?: string;
    startingAfter?: string;
  };
}) {
  const [
    isLoadingTransactions,
    setLoadingTransactions
  ] = useState<boolean>(true)

  const [
    transactions,
    setTransactions
  ] = useState<Transaction[]>([]);

  const [
    isLoadingCategories,
    setLoadingCategories
  ] = useState<boolean>(true)

  const [
    categories,
    setCategories
  ] = useState<Category[]>([]);

  const query = searchParams?.query || '';
  const startingAfter = (searchParams?.startingAfter) || '';

//  const totalPages = await fetchTransactionsPages(query);

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
    fetchTransactions(query, startingAfter)
      .then(data => {
        setTransactions(data.transactions);
        setLoadingTransactions(false);
      })
      .catch(error => {
        console.error(error);
        setTransactions([]);
        setLoadingTransactions(false);
      });
  }, [query, startingAfter]);

  return (
    <div className="w-full">
      <div className="flex w-full items-center justify-between">
        <h1 className={`text-2xl`}>Transactions</h1>
      </div>
      <div className="mt-4 flex items-center justify-between gap-2 md:mt-8">
        <FilterBar accounts={accounts} users={users} />
        <Search placeholder="Search transactions..." />
        <CreateTransaction />
      </div>
      <TransactionsTable
        transactions={transactions}
        categories={categories}
      />
      <div className="mt-5 flex w-full justify-center">
        {/* <Pagination totalPages={totalPages} /> */}
      </div>
    </div>
  );
}