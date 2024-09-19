"use client"
import { Suspense, useEffect, useState } from 'react';
import { Inter } from "next/font/google";
import { PlusIcon } from "@heroicons/react/16/solid";
import clsx from 'clsx';
import { CategorizationCondition, CategorizationRule, Category } from '@/app/lib/definitions';
import { fetchCategories, fetchCategorizationConditions, fetchCategorizationRules } from '@/app/lib/data';
import NoRulesComponent from './NoRulesComponent';
import CategorizationRuleRow from './CategorizationRuleRow';
import About from './About';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

function CategorizationRulesContent() {
  const [isLoadingRules, setIsLoadingRules] = useState<boolean>(true)
  const [isLoadingConditions, setIsLoadingConditions] = useState<boolean>(true)
  const [isLoadingCategories, setIsLoadingCategories] = useState<boolean>(true)
  const [rules, setRules] = useState<CategorizationRule[]>([]);
  const [conditions, setConditions] = useState<CategorizationCondition[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);

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


  if (isLoadingRules || isLoadingConditions || isLoadingCategories) {
    return <div className={font.className}>Loading...</div>;
  }

  if (rules.length === 0) {
    return (
      <div className={font.className}>
        <About />
        <NoRulesComponent />
      </div>
    );
  }

  return (
    <div className={clsx("flex", font.className)}>
      {/* Left panel */}
      <div className="block flex-none w-40 mr-3">
        <div>Filters go here</div>
      </div>

      {/* Content */}
      <div className="flex-grow flex flex-col items-center w-full mx-auto">
        <About />
        <button
          className="inline-flex flex-none items-center justify-center \
                    h-10 max-w-s px-4 py-2 mb-6 border rounded-lg \
                    bg-theme-lgt-green hover:bg-theme-drk-green \
                    active:bg-theme-pressed-green active:scale-95 \
                    active:shadow-inner cursor-pointer"
        >
          <PlusIcon className="h-5 w-5" />
          <span className="text-m">Add new rule</span>
        </button>
        {rules.map((rule) => (
          <CategorizationRuleRow
            rule={rule}
            conditions={conditions}
            categories={categories}
          />
        ))}
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