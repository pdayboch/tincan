import { Account, CategorizationCondition } from "@/lib/definitions";
import { formatAccountLabel } from "@/lib/helpers";

export const MATCH_TYPES_FOR_FIELDS: { [key: string]: { [key: string]: string } } = {
  description: {
    exactly: "is exactly",
    starts_with: "starts with",
    ends_with: "ends with",
  },
  amount: {
    exactly: "is exactly",
    greater_than: "is greater than",
    less_than: "is less than",
  },
  date: {
    exactly: "is on",
    greater_than: "is after",
    less_than: "is before",
  },
  account: {
    exactly: "is",
  },
};

export const getFormattedMatchValue = (
  condition: CategorizationCondition,
  accounts: Account[]
): string => {
  if (condition.transactionField === 'account') {
    const account = accounts.find(acc =>
      acc.id === Number(condition.matchValue)
    );

    if (account) return formatAccountLabel(account);
  }

  // For non-account matchTypes, return the matchValue as is
  return condition.matchValue;
};