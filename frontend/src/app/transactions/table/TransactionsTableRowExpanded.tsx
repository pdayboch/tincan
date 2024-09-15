import { useEffect, useState } from 'react';
import clsx from 'clsx';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { ThreeDots } from 'react-loader-spinner';
import { parseISO, format } from 'date-fns';
import { ChevronDoubleUpIcon } from "@heroicons/react/24/outline";
import { Category, Transaction } from "../../lib/definitions";
import { formatCurrency } from '@/app/lib/helpers';
import CategoryDropdown from "@/app/ui/shared/CategoryDropdown";

interface TransactionTableRowExpandedProps {
  transaction: Transaction;
  categories: Category[];
  setExpandedRowTransactionId: React.Dispatch<React.SetStateAction<number | null>>;
  onUpdateTransactionDate: (transaction_id: number, newDate: string) => void;
  onUpdateTransactionDescription: (transaction_id: number, description: string) => void;
  onUpdateTransactionSubcategory: (transaction_id: number, newSubcategoryName: string) => void;
};

export default function TransactionTableRowExpanded({
  transaction,
  categories,
  setExpandedRowTransactionId,
  onUpdateTransactionDate,
  onUpdateTransactionDescription,
  onUpdateTransactionSubcategory
}: TransactionTableRowExpandedProps) {
  const [description, setDescription] = useState(transaction.description);
  const [isDescriptionLoading, setIsDescriptionLoading] = useState(false);
  const [isDescriptionSaved, setIsDescriptionSaved] = useState(true);

  useEffect(() => {
    const isSaved = description === transaction.description;
    setIsDescriptionSaved(isSaved);
  }, [description, transaction.description]);

  const handleDescriptionChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setDescription(event.target.value);
  }

  const handleDescriptionKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter' && !isDescriptionSaved) {
      handleSaveDescription();
    }
  }

  // Event handler for when description is saved:
  const handleSaveDescription = async () => {
    setIsDescriptionLoading(true);
    await onUpdateTransactionDescription(transaction.id, description);
    setIsDescriptionLoading(false);
    setIsDescriptionSaved(true)
  }

  // Event handler for when date is selected:
  const handleDateSelect = (date: Date | null) => {
    if (date) {
      const newDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
      onUpdateTransactionDate(transaction.id, newDate);
    }
  }

  const amountClass = clsx({
    'text-green-600': transaction.amount >= 0,
    'text-red-600': transaction.amount < 0,
  });

  const transactionDate = parseISO(transaction.transactionDate);

  return (<>
    {/* original row */}
    <tr
      key={transaction.id}
      className="expanded-row bg-neutral-50 mb-2 \
        text-sm last-of-type:border-none"
    >
      <td className="w-24 px-1 py-2 align-top whitespace-nowrap">
        <DatePicker
          className="w-full border border-gray-300 p-1 rounded-md"
          selected={transactionDate}
          isClearable={false}
          onChange={(date) => handleDateSelect(date)}
          fixedHeight
          popperPlacement="bottom-end"
          dateFormat="MM-dd-yyyy"
        />
      </td>
      <td className="w-64 px-1 py-2 align-top whitespace-nowrap">
        <div className="flex items-center">
          <input
            type="text"
            value={description}
            onChange={handleDescriptionChange}
            onKeyDown={handleDescriptionKeyDown}
            className={clsx("border p-1 flex-grow rounded-md",
              isDescriptionSaved ? "border-gray-300" : "border-red-500"
            )}
            style={{ outline: 'none' }}
          />
          <button
            onClick={handleSaveDescription}
            className={clsx("ml-2 p-1 w-[40px] h-[30px] text-white text-sm rounded \
              flex items-center justify-center",
              isDescriptionSaved || isDescriptionLoading ? "bg-gray-400" : "bg-blue-500"
            )}
            disabled={isDescriptionSaved || isDescriptionLoading}
          >
            {isDescriptionLoading ? (
              <div className="flex items-center justify-center w-full h-full">
                <ThreeDots
                  height="15"
                  width="15"
                  color="#ffffff"
                  ariaLabel="loading"
                />
              </div>
            ) : isDescriptionSaved ? (
              "Saved"
            ) : (
              "Save"
            )}
          </button>
        </div>
      </td>
      <td className="absolute w-48 p-2 align-top whitespace-nowrap">
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
      <td className={clsx("w-24 p-2 align-top whitespace-nowrap font-mono", amountClass)}>
        {formatCurrency(transaction.amount)}
      </td>
      <td>
        <div className="w-4" />
      </td>
    </tr>
    {/* expanded row */}
    <tr className="expanded-row bg-neutral-50">
      <td colSpan={5}>
        <hr />
        <div className="flex justify-between w-full h-40">
          {/* Additional transaction content here */}
          <div
            className="flex-none content-start pl-2 \
              flex flex-col text-sm"
          >
            <p>
              <b>Account: </b>
              {transaction.account.bank} {transaction.account.name}
            </p>
            <p>
              <b>Appears on statement as </b>
              {transaction.statementDescription}
            </p>
            <span>Split transaction</span>
          </div>
          <div
            className="w-7 h-full whitespace-nowrap \
              order-last flex-none justify-self-end\
              flex justify-center items-center  \
              cursor-pointer \
              hover:bg-slate-100 hover:rounded-lg \
              hover:border hover:border-bg-slate-100"
            onClick={() => setExpandedRowTransactionId(null)}
          >
            <ChevronDoubleUpIcon className="w-4 h-4" />
          </div>
        </div>
        <hr />
      </td>
    </tr>
  </>);
}