import { Transaction, TransactionUpdate } from "@/lib/definitions";
import { ChevronDoubleUpIcon } from "@heroicons/react/24/outline";

interface ExpandedTransactionRowProps {
  transaction: Transaction;
  setExpandedRowTransactionId: React.Dispatch<React.SetStateAction<number | null>>;
  onUpdateTransaction: (transactionId: number, data: TransactionUpdate) => void;
};

export default function ExpandedTransactionRow({
  transaction,
  setExpandedRowTransactionId,
  onUpdateTransaction
}: ExpandedTransactionRowProps) {

  return (
    <tr className="expanded-row bg-neutral-50" >
      <td colSpan={5}>
        <div className="flex justify-between w-full h-40">
          {/* Additional transaction content */}
          <div
            className="flex-none content-start mt-2 pl-2 flex flex-col text-sm">
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
            className="w-7 h-full whitespace-nowrap order-last flex-none flex
              justify-self-end justify-center items-center cursor-pointer
              hover:bg-slate-100 hover:rounded-lg hover:border hover:border-bg-slate-100"
            onClick={() => setExpandedRowTransactionId(null)}
          >
            <ChevronDoubleUpIcon className="w-4 h-4" />
          </div>
        </div>
        <hr />
      </td>
    </tr >
  );
}