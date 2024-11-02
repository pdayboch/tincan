import { Account, CategorizationRule } from "@/lib/definitions";
import CategorizationConditionRow from "./CategorizationConditionRow";
import { AddConditionButton } from "./AddConditionButton";
import { ExclamationTriangleIcon } from "@heroicons/react/16/solid";

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
  // We need to wrap the outer div's onClick handler in this function
  // to differentiate whether the whitespace was clicked on the AddConditionButton
  const handleRowClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const target = e.target as HTMLElement;
    const addButton = target.closest('button');
    // This checks whether the element that was clicked (or one of its ancestors)
    // is a <button> element. If target is a button or inside a button
    // (like a <span> inside the button), closest('button') will return the
    // button element.
    // If the click wasn't on or inside a button, it returns null.
    if (!addButton) {
      onClick();
    }
  };

  return (
    <div
      className="border border-gray-300 rounded-3xl w-full p-5 \
                  shadow-lg bg-white cursor-pointer"
      onClick={handleRowClick}
    >
      {/* Subcategory Assignment */}
      <div className="px-3 py-5 bg-blue-50 text-blue-900 rounded-lg">
        <span className="font-medium">Assign subcategory: </span>
        <span className="font-semibold">{rule.subcategory.name}</span>
      </div>

      <div className="space-y-4 mt-4">
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
                  <span className="absolute px-2 text-sm text-gray-500 bg-white">
                    AND
                  </span>
                </div>
              )}
            </div>
          ))
        ) : (
          // The rule has no conditions
          <div className="flex flex-col items-center justify-center py-3">
            <div className="flex items-center text-yellow-600">
              <ExclamationTriangleIcon className="w-6 h-6 mr-2" />
              <span className="text-base font-medium">
                This rule is missing conditions
              </span>
            </div>
            <div className="mt-4">
              <AddConditionButton onClick={onAddCondition} />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}