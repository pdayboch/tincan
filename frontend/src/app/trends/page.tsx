"use client"
import clsx from 'clsx';
import { Inter } from "next/font/google";
import { useEffect, useState } from 'react';
import Select from 'react-select';
import { Account, Category } from '@/lib/definitions';
import { fetchCategories } from '@/lib/api/category-api';
import { fetchAccounts } from '@/lib/api/account-api';
import AccountFilter from '@/components/filters/AccountFilter';
import SubcategoryFilter from '@/components/filters/SubcategoryFilter';
import TrendMenu, { TrendOption } from './TrendMenu';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

// Define chart options
const trendOptions: TrendOption[] = [
  { transactionType: 'Spending', trendType: ['Over Time', 'By Category'] },
  { transactionType: 'Income', trendType: ['Over Time', 'By Category'] },
  { transactionType: 'Net Income', trendType: ['Over Time'] },
];

// Time ranges for the dropdown
const timeRangesAndGroups = {
  "Month to date": "day",
  "Last month": "day",
  "Last 3 months": "month",
  "Last 6 months": "month",
  "Year to date": "month",
  "Last year": "month"
};

export default function Page() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedTimeRange, setSelectedTimeRange] = useState<string>("Last month");
  const [selectedTrend, setSelectedTrend] = useState<{
    transactionType: string,
    trendType: string
  }>({
    transactionType: "Spending",
    trendType: "Over Time"
  });

  // Fetch and store all categories
  useEffect(() => {
    fetchCategories()
      .then(data => setCategories(data['categories']))
      .catch(error => {
        console.error(error);
        setCategories([]);
      });
  }, []);

  // Fetch and store all accounts
  useEffect(() => {
    fetchAccounts()
      .then(data => {
        setAccounts(data);
      })
      .catch(error => {
        console.error(error);
        setAccounts([]);
      });
  }, []);

  const handleTimeRangeChange = (
    selectedOption: { value: string; label: string } | null
  ) => {
    if (selectedOption) setSelectedTimeRange(selectedOption.value);
  };

  const handleTrendSelection = (transactionType: string, trendType: string) => {
    setSelectedTrend({ transactionType, trendType });
  };

  return (
    <div
      className={clsx("flex h-full min-h-screen bg-gray-100", font.className)}
    >
      <div className="w-1/4 p-4 bg-white shadow-lg">
        {/* Left Sidebar Menu */}
        <TrendMenu
          trendOptions={trendOptions}
          selectedTrend={selectedTrend}
          onTrendSelection={handleTrendSelection}
        />
      </div>

      {/* Main Content Section */}
      <div className="flex-grow flex flex-col items-center w-full mx-auto p-6">
        {/* Filter Row */}
        <div className="flex flex-row justify-between w-3/4 mb-6 space-x-4">

          {/* Account Filter */}
          <div className="w-1/3">
            <AccountFilter
              accounts={accounts}
            />
          </div>

          {/* Subcategory Filter */}
          <div className="w-1/3">
            <SubcategoryFilter
              categories={categories}
            />
          </div>

          {/* Time Range Filter */}
          <div className="w-1/3">
            <Select
              options={Object.keys(timeRangesAndGroups).map(range => ({
                value: range,
                label: range,
              }))}
              isClearable={false}
              placeholder="Select Time Range"
              onChange={handleTimeRangeChange}
              value={{ value: selectedTimeRange, label: selectedTimeRange }}
            />
          </div>
        </div>

        {/* Chart Area */}
        <div className="flex flex-col items-center w-full h-64 bg-white shadow-md rounded-lg p-6">
          {/* Placeholder for the chart */}
          <h3 className="text-lg font-semibold">Chart Placeholder</h3>
          <p className="text-gray-500">This is where the chart will go, using dummy data for now.</p>
        </div>
      </div>
    </div>
  );
}