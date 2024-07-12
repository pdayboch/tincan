import { Transaction } from "../../lib/definitions";

interface TransactionTableMobileRowProps {
  transaction: Transaction
};

export default function TransactionTableRow({transaction}: TransactionTableMobileRowProps) {
  return (
    <div
      key={transaction.id}
      className="mb-2 w-full rounded-md bg-white p-4"
    >
      <div className="flex items-center justify-between border-b pb-4">
        <div>
          <div className="mb-2 flex items-center">
            <p>{transaction.description}</p>
          </div>
          <p className="text-sm text-gray-500">Chase Freedom</p>
        </div>
        Food and something
      </div>
      <div className="flex w-full items-center justify-between pt-4">
        <div>
          <p className="text-xl font-medium">
            $50.00
          </p>
          <p>6/20/2024</p>
        </div>
        <div className="flex justify-end gap-2">
          some column
        </div>
      </div>
    </div>
  );
}