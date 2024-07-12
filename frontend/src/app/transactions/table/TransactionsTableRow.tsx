import React, { useState } from 'react';
import { BarsArrowDownIcon } from "@heroicons/react/24/outline";
import { Category, Transaction } from "../../lib/definitions";
import CategoryDropdown from "@/app/ui/shared/CategoryDropdown";
import { updateTransaction } from "@/app/lib/data";

interface TransactionTableRowProps {
  transaction: Transaction;
  categories: Category[];
};

export default function TransactionTableRow({
  transaction, categories
}: TransactionTableRowProps) {
  // Helper function to format amount as dollar value
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
    }).format(amount)
  };

  const [currentCategory, setCurrentCategory] = useState(transaction.subcategory.name);
  const updateTransactionSubcategory = async (subcategory_name: string):Promise<boolean> => {
    try {
      await updateTransaction(transaction.id, { subcategory_name: subcategory_name })
      setCurrentCategory(subcategory_name);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.log(`Error updating transaction ${error.message}`)
      } else {
        console.log('Error updating transaction: An unknown error occurred');
      }
      return false;
    }
  };

  return (
    <tr
      key={transaction.id}
      className="bg-theme-lgt-green hover:bg-theme-drk-green w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
    >
      <td className="whitespace-nowrap px-2 py-2">
        {transaction.transaction_date}
      </td>
      <td className="whitespace-nowrap pl-6 pr-3 py-2">
        <div className="flex items-center gap-2">
          <p>{transaction.description}</p>
        </div>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <p>Chase Freedom</p>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <p>{transaction.user.name}</p>
      </td>
      <td className="relative whitespace-nowrap px-3 py-2">
        <CategoryDropdown
        categories={categories}
        currentCategory={currentCategory}
        onUpdateSubcategory={updateTransactionSubcategory}
      />
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <p>{formatCurrency(transaction.amount)}</p>
      </td>
      <td className="whitespace-nowrap pl-6 pr-3 py-2 w-8">
        <div className="flex justify-end gap-3">
          <BarsArrowDownIcon className='w-7 h-5' />
        </div>
      </td>
    </tr>
  );
}