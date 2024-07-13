import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { ChevronDoubleUpIcon } from "@heroicons/react/24/outline";
import { Category, Transaction } from "../../lib/definitions";
import CategoryDropdown from "@/app/ui/shared/CategoryDropdown";
import { formatCurrency } from '@/app/lib/helpers';

interface TransactionTableRowExpandedProps {
  transaction: Transaction;
  categories: Category[];
  setExpandedRowTransactionId: React.Dispatch<React.SetStateAction<number | null>>;
  onUpdateTransactionDate: (transaction_id: number, newDate: string) => void;
  onUpdateTransactionSubcategory: (transaction_id: number, newSubcategoryName: string) => void;
};

export default function TransactionTableRowExpanded({
  transaction,
  categories,
  setExpandedRowTransactionId,
  onUpdateTransactionDate,
  onUpdateTransactionSubcategory
}: TransactionTableRowExpandedProps) {
  const [isDatePickerVisible, setDatePickerVisible] = useState<boolean>(false);

  const toggleDatePickerVisible = () =>
    setDatePickerVisible(!isDatePickerVisible)

  // Event handler for when date is selected:
  const handleDateSelect = (date: Date | null) => {
    if (date) {
      const newDate = date.toISOString().split('T')[0];
      onUpdateTransactionDate(transaction.id, newDate);
      setDatePickerVisible(false);
    } else {
      setDatePickerVisible(false);
    }
  }

  return (
    <tr
      key={transaction.id}
      className="bg-theme-drk-green w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg h-64"
    >
      <td className="whitespace-nowrap px-2 py-2">
        <div className="flex flex-col">
        <div className="flex-none h-4">
        <span onClick={() => setDatePickerVisible(true)}>
          {transaction.transaction_date}
        </span>
        </div>
        <div className="flex-none h-10">
        {isDatePickerVisible && (
          <DatePicker
            selected={new Date(transaction.transaction_date)}
            isClearable={false}
            onChange={handleDateSelect}
            onClickOutside={toggleDatePickerVisible}
            fixedHeight
            inline
          />
        )}
        </div>
        </div>
      </td>
      <td className="whitespace-nowrap pl-6 pr-3 py-2">
        <input
          type="text"
          value={transaction.description}
          className="w-full box-border p-2"
        />
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{transaction.account.bank} {transaction.account.name}</span>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{transaction.user.name}</span>
      </td>
      <td className="relative whitespace-nowrap px-3 py-2">
        <CategoryDropdown
          categories={categories}
          currentCategory={transaction.subcategory.name}
          onChange={
            (subcategoryName) => onUpdateTransactionSubcategory(
              transaction.id,
              subcategoryName
            )
          }
        />
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{formatCurrency(transaction.amount)}</span>
      </td>
      <td className="whitespace-nowrap p-0 w-1 h-full hover:bg-theme-lgt-green border border-black">
        <button
          className="w-full h-full flex justify-center items-center"
          onClick={() => setExpandedRowTransactionId(null)}
        >
          <ChevronDoubleUpIcon className='w-7 h-5 cursor-pointer' />
        </button>
      </td>
    </tr>
  );
}