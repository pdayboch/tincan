import {
  CategorizationCondition,
  CategorizationConditionUpdate
} from "@/lib/definitions";

export const EMPTY_CONDITION = {
  id: 0,
  categorizationRuleId: 0,
  transactionField: "description",
  matchType: "",
  matchValue: ""
}

export const NEW_RULE = {
  id: 0,
  category: { id: 0, name: "" },
  subcategory: { id: 0, name: "" },
  conditions: [EMPTY_CONDITION]
}

export const emptyConditionWithId = (id: number): CategorizationCondition => {
  return { ...EMPTY_CONDITION, id: id };
};

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

export const convertConditionToConditionUpdateObject = (
  condition: CategorizationCondition
): CategorizationConditionUpdate => {
  const { transactionField, matchType, matchValue } = condition;
  return {
    transactionField,
    matchType,
    matchValue
  };
};

export const validateCondition = (condition: CategorizationCondition) => {
  if (!condition.matchType) {
    return "Match type can't be blank";
  }

  if (!condition.matchValue) {
    return getBlankValueError(condition.transactionField);
  }

  if (condition.transactionField === "date") {
    const dateError = validateDate(condition.matchValue);
    if (dateError) return dateError;
  };

  return null;
};

const getBlankValueError = (transactionField: string) => {
  const name = transactionField === "date" ? "Date" :
    transactionField === "account" ? "Account" :
      "Match value";
  return `${name} can't be blank`;
};

const validateDate = (value: string) => {
  // Check date format
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/ // YYYY-MM-DD format
  if (!dateRegex.test(value)) {
    return "Date must be in the format 'YYYY-MM-DD'";
  }

  // Check date is valid
  const [year, month, day] = value.split("-").map(Number);
  const parsedDate = new Date(`${value}T00:00:00`);
  if (
    parsedDate.getFullYear() !== year ||
    parsedDate.getMonth() + 1 !== month ||
    parsedDate.getDate() !== day
  ) {
    return "Date is invalid";
  }

  return null;
}