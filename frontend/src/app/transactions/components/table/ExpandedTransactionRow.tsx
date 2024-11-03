import { Account, Transaction, TransactionUpdate } from "@/lib/definitions";
import { formatAccountLabel } from "@/lib/helpers";
import { ChevronDoubleUpIcon } from "@heroicons/react/24/outline";

interface ExpandedTransactionRowProps {
  transaction: Transaction;
  accounts: Account[];
  setExpandedRowTransactionId: React.Dispatch<React.SetStateAction<number | null>>;
  onUpdateTransaction: (transactionId: number, data: TransactionUpdate) => void;
};

export default function ExpandedTransactionRow({
  transaction,
  accounts,
  setExpandedRowTransactionId,
  onUpdateTransaction
}: ExpandedTransactionRowProps) {

  const account = accounts.find(a =>
    a.id === transaction.account.id
  );

  return (
    <tr className="expanded-row bg-neutral-50" >
      <td colSpan={5}>
        <div className="flex justify-between w-full h-40">
          <div className="flex-none content-start mt-2 pl-2 flex flex-col text-sm">
            <p>
              <b>Custodian: </b>
              {account?.user.name}
            </p>
            <p>
              <b>Account: </b>
              {formatAccountLabel(account, false)}
            </p>
            <p>
              <b>Appears on statement as </b>
              {transaction.statementDescription}
            </p>
            <span>Split transaction</span>
          </div>

          {/* Collapse Button */}
          <div
            className="w-7 h-full whitespace-nowrap order-last flex-none flex
              justify-self-end justify-center items-center cursor-pointer"
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