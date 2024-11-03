import { Account } from "@/lib/definitions";
import { formatAccountLabel } from "@/lib/helpers";
import clsx from "clsx";

interface ConditionMatchValueInputProps {
  value: string | undefined;
  transactionField: string;
  accounts: Account[];
  onChange: (newValue: string) => void;
  isDisabled: boolean;
  isInvalid: boolean;
}

export default function ConditionMatchValueInput({
  value,
  transactionField,
  accounts,
  onChange,
  isDisabled,
  isInvalid
}: ConditionMatchValueInputProps) {
  const placeholder = transactionField === "date"
    ? "Enter a date (yyyy-mm-dd)"
    : "Enter a value";

  return transactionField === "account" ? (
    <select
      className={clsx(
        "w-full md:w-80 border rounded p-2 h-[40px]",
        "bg-white text-gray-700",
        isInvalid && "border-red-500"
      )}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      disabled={isDisabled}
    >
      <option value="" disabled>Select an account</option>
      {accounts.map((account) => (
        <option key={account.id} value={account.id.toString()}>
          {formatAccountLabel(account)}
        </option>
      ))}
    </select>
  ) : (
    <input
      className={clsx(
        "w-full md:w-80 border rounded p-2 h-[40px]",
        isInvalid && "border-red-500"
      )}
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      disabled={isDisabled}
    />
  );
}