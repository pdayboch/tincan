import {
  CategorizationRule,
  CategorizationCondition,
  Category
} from "@/app/lib/definitions";
import CategorizationConditionRow from "./CategorizationConditionRow";

interface CategorizationRuleRowProps {
  rule: CategorizationRule,
  conditions: CategorizationCondition[],
  categories: Category[]
}

export default function CategorizationRuleRow({
  rule,
  conditions,
  categories
}: CategorizationRuleRowProps) {
  const ruleConditions = conditions.filter(
    condition => condition.categorizationRuleId === rule.id
  );

  const category = categories.find(
    (c) => c.id === rule.categoryId
  );

  const subcategory = category?.subcategories.find(
    (s) => s.id === rule.subcategoryId
  );

  return (
    <div className="border border-gray-300 rounded-3xl w-full max-w-3xl p-6 mb-6 shadow-lg bg-white">
      <div className="space-y-4">
        {ruleConditions.map((condition, index) => (
          <div key={condition.id}>
            <CategorizationConditionRow condition={condition} />
            {index < ruleConditions.length - 1 && (
              <div className="relative flex items-center justify-center my-4">
                <hr className="w-full border-gray-300" />
                <span className="absolute px-2 text-sm text-gray-500 bg-white">AND</span>
              </div>
            )}
          </div>
        ))}
      </div>
      <div className="mt-6 p-4 bg-blue-50 text-blue-900 rounded-lg">
        <span className="font-medium">Then assign subcategory: </span>
        <span className="font-semibold">{subcategory?.name || "Error: Subcategory not found"}</span>
      </div>
    </div>
  );
}