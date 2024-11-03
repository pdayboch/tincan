"use client"
import { Suspense, useEffect, useState } from 'react';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import { Inter } from "next/font/google";
import clsx from 'clsx';
import {
  Account,
  CategorizationRule,
  Category,
  User
} from '@/lib/definitions';
import CategorizationRuleRow from './components/CategorizationRuleRow';
import About from './components/About';
import Search from '@/components/Search';
import { fetchCategories } from '@/lib/api/category-api';
import { fetchUsers } from '@/lib/api/user-api';
import { fetchAccounts } from '@/lib/api/account-api';
import { fetchCategorizationRules } from '@/lib/api/categorization-rule-api';
import {
  filterByAccounts,
  filterBySearchString,
  filterBySubcategories
} from './utils/filter-helpers';
import EditableCategorizationRule from './components/EditableCategorizationRule';
import AddRuleButton from './components/AddRuleButton';
import ApplyRulesButton from './components/ApplyRulesButton';
import { EMPTY_CONDITION, NEW_RULE } from './utils/rule-helpers';
import NoRulesComponent from './components/NoRulesComponent';
import AccountFilter from '@/components/filters/AccountFilter';
import SubcategoryFilter from '@/components/filters/SubcategoryFilter';

const font = Inter({ weight: ["400"], subsets: ['latin'] });

function CategorizationRulesContent() {
  const [rules, setRules] = useState<CategorizationRule[]>([]);
  const [filteredRules, setFilteredRules] = useState<CategorizationRule[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [isAddingNewRule, setIsAddingNewRule] = useState(false);
  const [editingRule, setEditingRule] = useState<CategorizationRule | null>(null);


  // fetch and store all rules
  useEffect(() => {
    fetchCategorizationRules()
      .then(data => {
        const sortedData = data.sort((a, b) => b.id - a.id);
        setRules(data);
      })
      .catch(error => {
        console.error(error);
        setRules([]);
      });
  }, []);

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  // filter rules when search updated
  useEffect(() => {
    const searchString = searchParams.get('searchString') || '';
    const accounts = searchParams.getAll('accounts[]');
    const subcategories = searchParams.getAll('subcategories[]');

    // Apply all the filters using the helper functions
    let filtered = rules;
    filtered = filterBySearchString(filtered, searchString);
    filtered = filterByAccounts(filtered, accounts);
    filtered = filterBySubcategories(filtered, subcategories);
    setFilteredRules(filtered);
  }, [searchParams, rules])

  // fetch and store all categories
  useEffect(() => {
    fetchCategories()
      .then(data => {
        setCategories(data['categories']);
      })
      .catch(error => {
        console.error(error);
        setCategories([]);
      });
  }, []);

  // fetch and store all accounts
  useEffect(() => {
    fetchAccounts()
      .then(data => {
        // Filter out accounts named "Cash" or without an accountType
        const filteredAccounts = data.filter(
          (account: Account) => account.name !== "Cash" && account.accountType
        );
        setAccounts(filteredAccounts);
      })
      .catch(error => {
        console.error(error);
        setAccounts([]);
      });
  }, []);

  const handleSearch = (term: string) => {
    const params = new URLSearchParams(searchParams);

    if (term) {
      params.set('searchString', term);
    } else {
      params.delete('searchString');
    }
    replace(`${pathname}?${params.toString()}`)
  }

  const handleAddConditionToEmptyRule = (emptyRule: CategorizationRule) => {
    const ruleWithNewCondition = {
      ...emptyRule,
      conditions: [EMPTY_CONDITION]
    };
    setEditingRule(ruleWithNewCondition);
  }

  const handleAddNewRule = () => {
    setIsAddingNewRule(true);
  }

  const handleCreateRule = (newRule: CategorizationRule) => {
    setRules((prevRules) => [newRule, ...prevRules]);
    setIsAddingNewRule(false);
  };

  const handleUpdateRule = async (updatedRule: CategorizationRule) => {
    setRules((prevRules) =>
      prevRules.map((rule) =>
        rule.id === updatedRule.id ? updatedRule : rule
      )
    );
    setEditingRule(null);
  };

  const handleDeleteRule = async (id: number) => {
    const updatedRules = rules.filter(rule => rule.id != id)
    setRules(updatedRules);
    setEditingRule(null);
  }

  const handleApplyRules = () => {
    // TODO - Implement later
  };

  // No categorization rules yet
  if (rules.length === 0 && !isAddingNewRule) {
    return (
      <div className={font.className}>
        <About />
        <NoRulesComponent
          onAddNewRule={handleAddNewRule}
        />
      </div>
    );
  }

  // Categorization rules exist
  return (
    <div className={clsx("flex flex-row h-full", font.className)}>
      {/* Main content area */}
      <div className="flex-grow p-4 flex flex-col">
        <About />

        {/* Top controls bar */}
        <div className="flex items-center gap-4 mb-4">
          <Search
            placeholder='Search rules...'
            value={searchParams.get('searchString')?.toString()}
            onSearch={handleSearch}
          />
          <AddRuleButton
            label={"Add new rule"}
            onClick={handleAddNewRule}
            disabled={isAddingNewRule}
          />
        </div>

        {/* Filter Dropdowns */}
        <div className="flex gap-4 mb-6 p-4 bg-gray-50 rounded-lg shadow-sm border border-gray-200">
          <div className="flex flex-col w-1/2">
            <label className="text-sm font-medium text-gray-700 mb-1">
              Account Filter
            </label>
            <AccountFilter
              accounts={accounts}
            />
          </div>
          <div className="flex flex-col w-1/2">
            <label className="text-sm font-medium text-gray-700 mb-1">
              Subcategory Filter
            </label>
            <SubcategoryFilter
              categories={categories}
            />
          </div>
        </div>

        {/* Scrollabe Rules List */}
        <div className="flex-grow space-y-6 pr-2 overflow-y-scroll max-h-screen-300 mt-2">
          {isAddingNewRule && (
            <EditableCategorizationRule
              rule={NEW_RULE}
              categories={categories}
              accounts={accounts}
              onSave={handleCreateRule}
              onCancel={() => setIsAddingNewRule(false)}
              onDelete={() => setIsAddingNewRule(false)}
              isNewRule
            />
          )}

          {filteredRules.map((rule) => (
            editingRule?.id === rule.id ? (
              <EditableCategorizationRule
                key={rule.id}
                rule={editingRule}
                categories={categories}
                accounts={accounts}
                onCancel={() => setEditingRule(null)}
                onSave={(updatedRule) => handleUpdateRule(updatedRule)}
                onDelete={() => handleDeleteRule(rule.id)}
                isNewRule={false}
              />
            ) : (
              <CategorizationRuleRow
                key={rule.id}
                rule={rule}
                accounts={accounts}
                onAddCondition={() => handleAddConditionToEmptyRule(rule)}
                onClick={() => setEditingRule(rule)}
              />
            )
          ))}
        </div>
      </div>

      {/* Right sidebar for Job */}
      <div className="flex flex-col w-1/5 p-4 border-l border-gray-300 space-y-4">
        <ApplyRulesButton
          onClick={handleApplyRules}
        />

        {/* Job status display */}
        {/* TODO */}
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