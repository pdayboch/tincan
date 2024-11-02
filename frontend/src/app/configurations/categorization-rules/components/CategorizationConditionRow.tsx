import { Account, CategorizationCondition } from "@/lib/definitions";
import { getFormattedMatchValue, MATCH_TYPES_FOR_FIELDS } from "../utils/formatting-helpers";

interface CategorizationConditionRowProps {
  condition: CategorizationCondition;
  accounts: Account[];
}

const getMatchTypeLabel = (transactionField: string, matchType: string): string => {
  return MATCH_TYPES_FOR_FIELDS[transactionField]?.[matchType] || "<unknown match_type>";
};

export default function CategorizationConditionRow({
  condition,
  accounts
}: CategorizationConditionRowProps) {
  const matchTypeLabel = getMatchTypeLabel(condition.transactionField, condition.matchType);
  return (
    <div className="flex flex-col space-y-1 p-3 bg-gray-100 rounded-lg shadow-sm">
      <div className="text-lg font-medium">
        <span>
          when transaction
        </span>
        <span className="ml-1 font-semibold">
          {condition.transactionField}
        </span>
      </div>
      <div className="text-sm text-gray-600">
        <span>
          {matchTypeLabel}
        </span>
        <span className="ml-1 font-semibold">
          {getFormattedMatchValue(condition, accounts)}
        </span>
      </div>
    </div>
  );
}