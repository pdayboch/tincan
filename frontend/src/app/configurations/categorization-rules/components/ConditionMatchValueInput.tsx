import { Account } from "@/lib/definitions";
import { formatAccountLabel } from "../utils/formatting-helpers";

interface ConditionMatchValueInputProps {
  value: string | undefined;
  transactionField: string;
  accounts: Account[];
  onChange: (newValue: string) => void;
  disabled: boolean;
}

export default function ConditionMatchValueInput({
  value,
  transactionField,
  accounts,
  onChange,
  disabled
}: ConditionMatchValueInputProps) {
  return transactionField === "account" ? (
    <select
      className="w-full md:w-80 border border-gray-300 rounded p-2 \
                      bg-white text-gray-700"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      disabled={disabled}
    >
      {accounts.map((account) => (
        <option key={account.id} value={account.id.toString()}>
          {formatAccountLabel(account)}
        </option>
      ))}
    </select>
  ) : (
    <input
      className="w-full md:w-80 border border-gray-300 rounded p-2"
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder="Value"
      disabled={disabled}
    />
  );
}