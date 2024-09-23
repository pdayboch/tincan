"use client"
import { Suspense, useEffect, useState } from 'react';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import { Inter } from "next/font/google";
import { PlusIcon, PlayIcon } from "@heroicons/react/16/solid";
import clsx from 'clsx';
import {
  Account,
  CategorizationCondition,
  CategorizationRule,
  Category,
  User
} from '@/app/lib/definitions';
import {
  fetchAccounts,
  fetchCategories,
  fetchCategorizationConditions,
  fetchCategorizationRules,
  fetchUsers
} from '@/app/lib/data';
import Filters from './CategorizationRuleFilters';
import NoRulesComponent from './NoRulesComponent';
import CategorizationRuleRow from './CategorizationRuleRow';
import About from './About';
import Search from '@/components/Search';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

function CategorizationRulesContent() {
  const [isLoadingRules, setIsLoadingRules] = useState<boolean>(true)
  const [isLoadingConditions, setIsLoadingConditions] = useState<boolean>(true)
  const [isLoadingCategories, setIsLoadingCategories] = useState<boolean>(true)
  const [isLoadingUsers, setIsLoadingUsers] = useState<boolean>(true)
  const [isLoadingAccounts, setIsLoadingAccounts] = useState<boolean>(true)
  const [rules, setRules] = useState<CategorizationRule[]>([]);
  const [conditions, setConditions] = useState<CategorizationCondition[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleSearch = (term: string) => {
    const params = new URLSearchParams(searchParams);

    if (term) {
      params.set('searchString', term);
    } else {
      params.delete('searchString');
    }
    replace(`${pathname}?${params.toString()}`)
  }

  // fetch and store all conditions
  useEffect(() => {
    setIsLoadingConditions(true);
    fetchCategorizationConditions()
      .then(data => {
        setConditions(data);
        setIsLoadingConditions(false);
      })
      .catch(error => {
        console.error(error);
        setConditions([]);
        setIsLoadingConditions(false);
      });
  }, []);

  // fetch and store all rules
  useEffect(() => {
    setIsLoadingRules(true);
    fetchCategorizationRules()
      .then(data => {
        setRules(data);
        setIsLoadingRules(false);
      })
      .catch(error => {
        console.error(error);
        setRules([]);
        setIsLoadingRules(false);
      });
  }, []);

  // fetch and store all categories
  useEffect(() => {
    setIsLoadingCategories(true);
    fetchCategories()
      .then(data => {
        setCategories(data['categories']);
        setIsLoadingCategories(false);
      })
      .catch(error => {
        console.error(error);
        setCategories([]);
        setIsLoadingCategories(false);
      });
  }, []);

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


  if (isLoadingRules ||
    isLoadingConditions ||
    isLoadingCategories ||
    isLoadingUsers ||
    isLoadingAccounts
  ) {
    return <div className={font.className}>Loading...</div>;
  }

  // No categorization rules configured
  if (rules.length === 0) {
    return (
      <div className={font.className}>
        <About />
        <NoRulesComponent />
      </div>
    );
  }

  // Categorization rules exist.
  return (
    <div className={clsx("flex", font.className)}>
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <Filters
          categories={categories}
          accounts={accounts}
          users={users}
        />
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col items-center w-full mx-auto max-w-4xl">
        <About />
        <div className="flex items-center justify-between w-full gap-2 mt-2 mb-5 h-10">
          <Search
            placeholder='Search rules...'
            value={searchParams.get('searchString')?.toString()}
            onSearch={handleSearch}
          />

          <div className="flex gap-2">
            <button
              className="inline-flex flex-none items-center justify-center \
                    h-10 max-w-s px-4 py-2 border rounded-lg \
                    bg-theme-lgt-green hover:bg-theme-drk-green \
                    active:bg-theme-pressed-green active:scale-95 \
                    active:shadow-inner cursor-pointer"
            >
              <PlusIcon className="h-5 w-5" />
              <span className="hidden md:inline text-m">Add new rule</span>
            </button>
            <button
              className="inline-flex flex-none items-center justify-center \
                    h-10 max-w-s px-4 py-2 border rounded-lg \
                    bg-theme-lgt-green hover:bg-theme-drk-green \
                    active:bg-theme-pressed-green active:scale-95 \
                    active:shadow-inner cursor-pointer"
            >
              <PlayIcon className="h-5 w-5" />
              <span className="hidden md:inline text-m">Apply rules to uncategorized</span>
            </button>
          </div>
        </div>

        <div className="w-full">
          {rules.map((rule) => (
            <CategorizationRuleRow
              key={rule.id}
              rule={rule}
              conditions={conditions}
              categories={categories}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

export default function Page() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <CategorizationRulesContent />
    </Suspense>
  );
}