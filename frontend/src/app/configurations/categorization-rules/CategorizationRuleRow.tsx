import { Account, CategorizationRule } from "@/lib/definitions";
import CategorizationConditionRow from "./CategorizationConditionRow";
import { AddConditionButton } from "./components/AddConditionButton";

interface CategorizationRuleRowProps {
  rule: CategorizationRule,
  accounts: Account[],
  onAddCondition: () => void;
  onClick: () => void;
}

export default function CategorizationRuleRow({
  rule,
  accounts,
  onAddCondition,
  onClick
}: CategorizationRuleRowProps) {
  return (
    <div
      className="border border-gray-300 rounded-3xl w-full p-6 mb-6 \
                  shadow-lg bg-white"
      onClick={onClick}
    >
      <div className="space-y-4">
        {rule.conditions.length > 0 ? (
          // The rule has conditions
          rule.conditions.map((condition, index) => (
            <div key={condition.id}>
              <CategorizationConditionRow
                condition={condition}
                accounts={accounts}
              />
              {index < rule.conditions.length - 1 && (
                <div className="relative flex items-center justify-center my-4">
                  <hr className="w-full border-gray-300" />
                  <span className="absolute px-2 text-sm text-gray-500 bg-white">AND</span>
                </div>
              )}
            </div>
          ))
        ) : (
          // The rule has no conditions
          <div className="flex justify-center py-6">
            <AddConditionButton
              onClick={onAddCondition}
            />
          </div>
        )}
      </div>
      <div className="mt-6 p-4 bg-blue-50 text-blue-900 rounded-lg">
        <span className="font-medium">Then assign subcategory: </span>
        <span className="font-semibold">{rule.subcategory.name}</span>
      </div>
    </div>
  );
}