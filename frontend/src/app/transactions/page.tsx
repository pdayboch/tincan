"use client"
import { useState, useEffect, Suspense } from 'react'
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import Search from '../../components/Search';
import { CreateTransaction } from './buttons';
import TransactionsTable from './table/TransactionsTable';
import Filters from './TransactionFilters';
import { Account, Category, Transaction, TransactionMetaData, User } from '../../lib/definitions';
import { Inter } from "next/font/google";
import clsx from 'clsx';
import { fetchUsers } from '@/lib/api/user-api';
import { fetchAccounts } from '@/lib/api/account-api';
import { fetchCategories } from '@/lib/api/category-api';
import { fetchTransactions } from '@/lib/api/transaction-api';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

function TransactionsContent() {
  const [isLoadingTransactions, setLoadingTransactions] = useState<boolean>(true)

  const [transactions, setTransactions] = useState<Transaction[]>([]);

  const [transactionMetaData, setTransactionMetaData] =
    useState<TransactionMetaData>({
      totalCount: 0,
      filteredCount: 0,
      prevPage: null,
      nextPage: null
    })

  const [isLoadingCategories, setLoadingCategories] = useState<boolean>(true)

  const [categories, setCategories] = useState<Category[]>([]);

  const [isLoadingAccounts, setLoadingAccounts] = useState<boolean>(true);

  const [accounts, setAccounts] = useState<Account[]>([]);

  const [isLoadingUsers, setLoadingUsers] = useState<boolean>(true);

  const [users, setUsers] = useState<User[]>([]);

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleSearch = (term: string) => {
    const params = new URLSearchParams(searchParams);
    params.delete('startingAfter');
    params.delete('endingBefore');

    if (term) {
      params.set('searchString', term);
    } else {
      params.delete('searchString');
    }
    replace(`${pathname}?${params.toString()}`)
  }

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

  if (isLoadingCategories ||
    isLoadingUsers ||
    isLoadingAccounts
  ) {
    return <div className={font.className}>Loading...</div>;
  }

  return (
    <div className={clsx("flex", font.className)}>
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <Filters accounts={accounts} users={users} />
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col w-full mx-auto">
        <div className="flex items-center justify-between gap-2 my-3 h-10">
          <Search
            placeholder="Search transactions..."
            value={searchParams.get('searchString')?.toString()}
            onSearch={handleSearch}
          />
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

export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <TransactionsContent />
    </Suspense>
  );
}