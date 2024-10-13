import { CategorizationCondition } from "@/lib/definitions";

export const EMPTY_CONDITION = {
  id: 0,
  categorizationRuleId: 0,
  transactionField: "description",
  matchType: "exactly",
  matchValue: ""
}

export const NEW_RULE = {
  id: 0,
  category: { id: 0, name: "" },
  subcategory: { id: 0, name: "" },
  conditions: [EMPTY_CONDITION]
}

export function areConditionsEqual(
  condition1: CategorizationCondition,
  condition2: CategorizationCondition
): boolean {
  return (
    condition1.transactionField === condition2.transactionField &&
    condition1.matchType === condition2.matchType &&
    condition1.matchValue === condition2.matchValue
  );
}