"use client"
import { Suspense, useEffect, useState } from 'react';
import { useSearchParams, usePathname, useRouter } from 'next/navigation';
import { Inter } from "next/font/google";
import clsx from 'clsx';
import {
  Account,
  CategorizationRule,
  CategorizationRuleUpdate,
  Category,
  User
} from '@/lib/definitions';
import Filters from './CategorizationRuleFilters';
import NoRulesComponent from './NoRulesComponent';
import CategorizationRuleRow from './CategorizationRuleRow';
import About from './About';
import Search from '@/components/Search';
import { fetchCategories } from '@/lib/api/category-api';
import { fetchUsers } from '@/lib/api/user-api';
import { fetchAccounts } from '@/lib/api/account-api';
import {
  fetchCategorizationRules,
  createCategorizationRule,
  updateCategorizationRule
} from '@/lib/api/categorization-rule-api';
import {
  filterByAccounts,
  filterBySearchString,
  filterBySubcategories
} from './utils/filter-helpers';
import EditableCategorizationRule from './EditableCategorizationRule';
import AddRuleButton from './components/AddRuleButton';
import ApplyRulesButton from './components/ApplyRulesButton';
import { EMPTY_CONDITION, NEW_RULE } from './utils/rule-helpers';

const font = Inter({ weight: ["400"], subsets: ['latin'] });

function CategorizationRulesContent() {
  const [rules, setRules] = useState<CategorizationRule[]>([]);
  const [filteredRules, setFilteredRules] = useState<CategorizationRule[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [isAddingNewRule, setIsAddingNewRule] = useState(false);
  const [editingRule, setEditingRule] = useState<CategorizationRule | null>(null);


  // fetch and store all rules
  useEffect(() => {
    fetchCategorizationRules()
      .then(data => {
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

  // fetch and store all users
  useEffect(() => {
    fetchUsers()
      .then(data => {
        setUsers(data);
      })
      .catch(error => {
        console.error(error);
        setUsers([]);
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
    }
    setEditingRule(ruleWithNewCondition);
  }

  const handleAddNewRule = () => {
    setIsAddingNewRule(true);
  }

  const handleCreateRule = async (
    newRule: CategorizationRuleUpdate
  ) => {
    try {
      const createdRule = await createCategorizationRule(newRule);
      setRules((prevRules) => [createdRule, ...prevRules]);
      setIsAddingNewRule(false);
    } catch (error) {
      console.error("Error saving rule:", error);
    }
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
  if (rules.length === 0) {
    return (
      <div className={font.className}>
        <About />
        {isAddingNewRule ? (
          <div className="flex items-center justify-center max-w-3xl">
            {/* <EditableCategorizationRule
              rule={NEW_RULE}
              categories={categories}
              accounts={accounts}
              onSave={handleCreateRule}
              onCancel={() => setIsAddingNewRule(false)}
              onDelete={() => setIsAddingNewRule(false)}
            /> */}
          </div>
        ) : (
          <NoRulesComponent
            onAddNewRule={handleAddNewRule}
          />
        )}
      </div>
    );
  }

  // Categorization rules exist
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
      <div className="flex-grow flex flex-col items-center \
                      w-full mx-auto max-w-4xl"
      >
        <About />
        <div className="flex items-center justify-between \
                        w-full gap-2 mt-2 mb-5 h-10"
        >
          <Search
            placeholder='Search rules...'
            value={searchParams.get('searchString')?.toString()}
            onSearch={handleSearch}
          />

          <div className="flex gap-2">
            <AddRuleButton
              label={"Add new rule"}
              onClick={handleAddNewRule}
              disabled={isAddingNewRule}
            />
            <ApplyRulesButton
              onClick={handleApplyRules}
            />
          </div>
        </div>
        <div className="w-full">
          {isAddingNewRule && (
            <div>
            </div>
            // New rule if adding a new rule
            // <NewCategorizationRule
            //   rule={NEW_RULE}
            //   categories={categories}
            //   accounts={accounts}
            //   onSave={handleCreateRule}
            //   onCancel={() => setIsAddingNewRule(false)}
            // />
          )}

          {filteredRules.map((rule) => (
            editingRule?.id === rule.id ? (
              <EditableCategorizationRule
                key={rule.id}
                rule={rule}
                categories={categories}
                accounts={accounts}
                onCancel={() => setEditingRule(null)}
                onSave={(updatedRule) => handleUpdateRule(updatedRule)}
                onDelete={() => handleDeleteRule(rule.id)}
              />
            ) : (
              < CategorizationRuleRow
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