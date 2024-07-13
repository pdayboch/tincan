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
      className="cursor-pointer bg-theme-lgt-green hover:bg-theme-drk-green w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
    >
      <td className="whitespace-nowrap px-2 py-2">
        <span>{transaction.transaction_date}</span>
      </td>
      <td className="whitespace-nowrap pl-6 pr-3 py-2">
          <span>{transaction.description}</span>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{transaction.account.bank} {transaction.account.name}</span>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{transaction.user.name}</span>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{transaction.subcategory.name}</span>
      </td>
      <td className="whitespace-nowrap px-3 py-2">
        <span>{formatCurrency(transaction.amount)}</span>
      </td>
      <td className="whitespace-nowrap pl-6 pr-3 py-2 w-3">
        <div className="flex justify-end gap-3">
          <BarsArrowDownIcon className='w-7 h-5' />
        </div>
      </td>
    </tr>
  );
}