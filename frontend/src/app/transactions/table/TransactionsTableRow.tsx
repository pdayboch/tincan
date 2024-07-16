import { BarsArrowDownIcon } from "@heroicons/react/24/outline";
import { Transaction } from "../../lib/definitions";
import { formatCurrency } from '@/app/lib/helpers';

interface TransactionTableRowProps {
  transaction: Transaction;
  onClick: (event: React.MouseEvent<HTMLTableRowElement>) => void;
};

export default function TransactionTableRow({
  transaction,
  onClick
}: TransactionTableRowProps) {
  return (
    <tr
      key={transaction.id}
      onClick={onClick}
      className="bg-white hover:bg-slate-100 w-full border-b \
      cursor-pointer \
      text-sm \
      last-of-type:border-none \
      [&:first-child>td:first-child]:rounded-tl-lg \
      [&:first-child>td:last-child]:rounded-tr-lg \
      [&:last-child>td:first-child]:rounded-bl-lg \
      [&:last-child>td:last-child]:rounded-br-lg"
    >
      <td className="whitespace-nowrap w-32 p-2">
        <span>{transaction.transaction_date}</span>
      </td>
      <td className="whitespace-nowrap p-2">
          <span>{transaction.description}</span>
      </td>
      <td className="whitespace-nowrap p-2">
        <span>{transaction.subcategory.name}</span>
      </td>
      <td className="whitespace-nowrap p-2">
        <span>{formatCurrency(transaction.amount)}</span>
      </td>
      <td className="whitespace-nowrap w-3">
        <div className="flex justify-end gap-3 w-4/5 h-4/5">
          <BarsArrowDownIcon className='w-full h-full' />
        </div>
      </td>
    </tr>
  );
}