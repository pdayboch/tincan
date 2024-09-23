import { CategorizationCondition } from "@/app/lib/definitions";

interface CategorizationConditionRowProps {
  condition: CategorizationCondition
}

export default function CategorizationConditionRow({
  condition
}: CategorizationConditionRowProps) {
  const getFormattedMatchType = (matchType: string) => {
    switch (matchType) {
      case 'starts_with':
        return 'starts with';
      case 'ends_with':
        return 'ends with';
      case 'exactly':
        return 'is exactly';
      case 'greater_than':
        return 'is greater than';
      case 'less_than':
        return 'is less than';
      default:
        return matchType;
    }
  };

  return (
    <div className="flex flex-col space-y-1 p-3 bg-gray-100 rounded-lg shadow-sm">
      <div className="text-lg font-medium">
        When transaction <span className="font-semibold">{condition.transactionField}</span>
      </div>
      <div className="text-sm text-gray-600">
        <span>{getFormattedMatchType(condition.matchType)}</span>
        <span className="font-semibold"> {condition.matchValue}</span>
      </div>
    </div>
  );
}