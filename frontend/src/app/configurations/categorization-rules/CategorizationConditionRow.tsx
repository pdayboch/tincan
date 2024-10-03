import { Account, CategorizationCondition } from "@/lib/definitions";
import { getFormattedMatchType, getFormattedMatchValue } from "./utils/formatting-helpers";

interface CategorizationConditionRowProps {
  condition: CategorizationCondition;
  accounts: Account[];
}

export default function CategorizationConditionRow({
  condition,
  accounts
}: CategorizationConditionRowProps) {
  return (
    <div className="flex flex-col space-y-1 p-3 bg-gray-100 rounded-lg shadow-sm">
      <div className="text-lg font-medium">
        <span>
          When transaction
        </span>
        <span className="ml-1 font-semibold">
          {condition.transactionField}
        </span>
      </div>
      <div className="text-sm text-gray-600">
        <span>
          {getFormattedMatchType(condition)}
        </span>
        <span className="font-semibold">
          {getFormattedMatchValue(condition, accounts)}
        </span>
      </div>
    </div>
  );
}