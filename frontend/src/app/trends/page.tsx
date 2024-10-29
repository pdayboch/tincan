"use client"
import clsx from 'clsx';
import { Inter } from "next/font/google";
import { useEffect, useMemo, useState } from 'react';
import Select, { SingleValue } from 'react-select';
import { Account, Category } from '@/lib/definitions';
import { fetchCategories } from '@/lib/api/category-api';
import { fetchAccounts } from '@/lib/api/account-api';
import AccountFilter from '@/components/filters/AccountFilter';
import SubcategoryFilter from '@/components/filters/SubcategoryFilter';
import TrendMenu, { TrendOption } from './TrendMenu';
import OverTimeChart from './OverTimeChart';
import { getStartAndEndDates } from './utils/date-helpers';
const font = Inter({ weight: ["400"], subsets: ['latin'] });

const trendOptions: TrendOption[] = [
  { transactionType: 'spend', trendType: ['Over Time', 'By Category'] },
  { transactionType: 'income', trendType: ['Over Time', 'By Category'] },
  { transactionType: 'net income', trendType: ['Over Time'] },
];

// Time ranges for the dropdown
type TimeRangesType = {
  id: string;
  value: string;
  label: string;
  groupBy: string;
}

const timeRanges: TimeRangesType[] = [
  {
    id: 'monthToDate',
    value: 'monthToDate',
    label: "Month to date",
    groupBy: "day"
  },
  {
    id: 'lastMonth',
    value: 'lastMonth',
    label: "Last month",
    groupBy: "day"
  },
  {
    id: 'last3Months',
    value: 'last3Months',
    label: "Last 3 months",
    groupBy: "month"
  },
  {
    id: 'last6Months',
    value: 'last6Months',
    label: "Last 6 months",
    groupBy: "month"
  },
  {
    id: 'yearToDate',
    value: 'yearToDate',
    label: "Year to date",
    groupBy: "month"
  },
  {
    id: 'lastYear',
    value: 'lastYear',
    label: "Last year",
    groupBy: "month"
  }
]

export default function Page() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedTimeRange, setSelectedTimeRange] = useState<TimeRangesType>(timeRanges[1]);
  const [selectedTrend, setSelectedTrend] = useState<{
    transactionType: string,
    trendType: string
  }>({
    transactionType: "spend",
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

  const handleTimeRangeChange = (selectedOption: SingleValue<TimeRangesType>) => {
    if (selectedOption) setSelectedTimeRange(selectedOption);
  };

  const handleTrendSelection = (transactionType: string, trendType: string) => {
    setSelectedTrend({ transactionType, trendType });
  };

  const { startDate, endDate } = useMemo(() =>
    getStartAndEndDates(selectedTimeRange.value), [selectedTimeRange]
  );

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

          {/* Time Range Selector */}
          <div className="w-1/3">
            <Select
              instanceId="time-range-select"
              options={timeRanges}
              isClearable={false}
              placeholder="Select Time Range"
              onChange={handleTimeRangeChange}
              value={selectedTimeRange}
            />
          </div>
        </div>

        {/* Chart Area */}
        <div className="flex flex-col items-center w-full h-1/2 bg-white shadow-md rounded-lg p-6">
          <h3 className="text-lg font-semibold">Transaction Trends</h3>
          <OverTimeChart
            startDate={startDate}
            endDate={endDate}
            type={selectedTrend.transactionType}
            groupBy={selectedTimeRange.groupBy}
          />
        </div>
      </div>
    </div>
  );
}