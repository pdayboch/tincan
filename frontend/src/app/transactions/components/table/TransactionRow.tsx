import { BarsArrowDownIcon } from "@heroicons/react/24/outline";
import { Transaction } from "@/lib/definitions";
import { formatCurrency, formatDate } from '@/lib/helpers';
import clsx from "clsx";
import { amountClass } from "../../helpers";

interface TransactionRowProps {
  transaction: Transaction;
  onClick: (event: React.MouseEvent<HTMLTableRowElement>) => void;
};

export default function TransactionRow({
  transaction,
  onClick
}: TransactionRowProps) {
  return (
    <tr
      key={transaction.id}
      onClick={onClick}
      className="bg-white hover:bg-slate-100 w-full border-b cursor-pointer
      text-sm last-of-type:border-none
      [&:first-child>td:first-child]:rounded-tl-lg
      [&:first-child>td:last-child]:rounded-tr-lg
      [&:last-child>td:first-child]:rounded-bl-lg
      [&:last-child>td:last-child]:rounded-br-lg"
    >
      {/* Date */}
      <td className="w-24 p-2 align-top whitespace-nowrap">
        <span>{formatDate(transaction.transactionDate)}</span>
      </td>

      {/* Description */}
      <td className="w-64 p-2 align-top whitespace-nowrap">
        <span>{transaction.description}</span>
      </td>

      {/* Subcategory */}
      <td className="w-48 p-2 align-top whitespace-nowrap">
        <span>{transaction.subcategory.name}</span>
      </td>

      {/* Amount */}
      <td
        className={clsx("w-24 p-2 align-top whitespace-nowrap font-mono",
          amountClass(transaction.amount)
        )}
      >
        {formatCurrency(transaction.amount)}
      </td>

      {/* Expand button */}
      <td className="w-4 whitespace-nowrap">
        <BarsArrowDownIcon className="w-4 h-4" />
      </td>
    </tr>
  );
}