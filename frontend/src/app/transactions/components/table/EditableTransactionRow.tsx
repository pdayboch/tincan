import { useEffect, useState } from 'react';
import clsx from 'clsx';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { ThreeDots } from 'react-loader-spinner';
import { parseISO } from 'date-fns';
import { Category, Transaction, TransactionUpdate } from "@/lib/definitions";
import { formatCurrency } from '@/lib/helpers';
import SubcategorySelector from '@/components/category/SubcategorySelector';
import { amountClass } from '../../helpers';

interface EditableTransactionRowProps {
  transaction: Transaction;
  categories: Category[];
  onUpdateTransaction: (transactionId: number, data: TransactionUpdate) => void;
};

export default function EditableTransactionRow({
  transaction,
  categories,
  onUpdateTransaction
}: EditableTransactionRowProps) {
  const [description, setDescription] = useState(transaction.description);
  const [isDescriptionLoading, setIsDescriptionLoading] = useState(false);
  const [isDescriptionSaved, setIsDescriptionSaved] = useState(true);

  useEffect(() => {
    const isSaved = description === transaction.description;
    setIsDescriptionSaved(isSaved);
  }, [description, transaction.description]);

  const handleDescriptionKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter' && !isDescriptionSaved) {
      handleSaveDescription();
    }
  }

  // Event handler for when description is saved:
  const handleSaveDescription = async () => {
    setIsDescriptionLoading(true);
    onUpdateTransaction(transaction.id, { description: description });
    setIsDescriptionLoading(false);
    setIsDescriptionSaved(true)
  }

  // Event handler for when date is selected:
  const handleDateSelect = (date: Date | null) => {
    if (date) {
      const newDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
      onUpdateTransaction(transaction.id, { transactionDate: newDate });
    }
  }

  const transactionDate = parseISO(transaction.transactionDate);

  return (
    <tr
      key={transaction.id}
      className="expanded-row bg-neutral-50 mb-2 text-sm last-of-type:border-none"
    >
      {/* Date */}
      <td className="w-24 px-1 align-top whitespace-nowrap">
        <DatePicker
          className="w-full h-9 border border-gray-300 p-1 rounded-md"
          selected={transactionDate}
          isClearable={false}
          onChange={(date) => handleDateSelect(date)}
          fixedHeight
          popperPlacement="bottom-end"
          dateFormat="MM-dd-yyyy"
        />
      </td>

      {/* Description */}
      <td className="w-64 px-1 align-top whitespace-nowrap">
        <div className="flex items-center h-9">
          <input
            type="text"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            onKeyDown={handleDescriptionKeyDown}
            className={clsx("border p-1 flex-grow rounded-md h-full",
              isDescriptionSaved ? "border-gray-300" : "border-red-500"
            )}
            style={{ outline: 'none' }}
          />
          <button
            onClick={handleSaveDescription}
            className={clsx("ml-2 p-1 w-[40px] h-full text-white text-sm rounded",
              "flex items-center justify-center",
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

      {/* Subcategory */}
      <td className="w-48 px-2 align-top whitespace-nowrap">
        <div className="w-full h-9 rounded-md">
          <SubcategorySelector
            categories={categories}
            currentSubcategory={{
              id: transaction.subcategory.id,
              name: transaction.subcategory.name
            }}
            onChange={(subcategory) =>
              onUpdateTransaction(transaction.id, { subcategoryId: subcategory.id })
            }
          />
        </div>
      </td>

      {/* Amount */}
      <td
        className={clsx("w-24 px-2 align-center whitespace-nowrap font-mono",
          amountClass(transaction.amount)
        )}
      >
        {formatCurrency(transaction.amount)}
      </td>

      <td>
        <div className="w-4" />
      </td>
    </tr>
  );
}