import { Category, Transaction } from "../../lib/definitions";
import TransactionsTableHeader from "./TransactionsTableHeader";
import TransactionsTableMobileRow from "./TransactionsTableMobileRow";
import TransactionsTableRow from "./TransactionsTableRow";

interface TransactionsTableProps {
  transactions: Transaction[];
  categories: Category[];
}

export default function TransactionsTable({
  transactions,
  categories
}: TransactionsTableProps) {
  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {transactions?.map((transaction) => (
              <TransactionsTableMobileRow
                key={transaction.id}
                transaction={transaction}
              />
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <TransactionsTableHeader />
            <tbody className="bg-white">
              {transactions.map((transaction) => (
              <TransactionsTableRow
                key={transaction.id}
                transaction={transaction}
                categories={categories}
              />
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
