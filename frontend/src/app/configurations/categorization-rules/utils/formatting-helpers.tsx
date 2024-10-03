import { Account, CategorizationCondition } from "@/lib/definitions";

export const getFormattedMatchType = (
  condition: CategorizationCondition
): string => {
  if (condition.transactionField === 'account') return 'is ';
  if (condition.transactionField === 'amount') return amountFormattedMatchType(condition);

  switch (condition.matchType) {
    case 'starts_with':
      return 'starts with ';
    case 'ends_with':
      return 'ends with ';
    case 'exactly':
      return 'is exactly ';
    case 'greater_than':
      return 'is greater than ';
    case 'less_than':
      return 'is less than ';
    default:
      return '<unknown match_type> ';
  }
};

const amountFormattedMatchType = (
  condition: CategorizationCondition
): string => {
  switch (condition.matchType) {
    case 'exactly':
      return 'is exactly $';
    case 'greater_than':
      return 'is greater than $';
    case 'less_than':
      return 'is less than $';
    default:
      return '<unknown match_type> ';
  }
};

export const getFormattedMatchValue = (
  condition: CategorizationCondition,
  accounts: Account[]
): string => {
  if (condition.transactionField === 'account') {
    // Find the account with the matching id
    const account = accounts.find(acc => acc.id === Number(condition.matchValue));
    // If account is found, return the nickname or the bankName and name
    if (account) return account.nickname || `${account.bankName} ${account.name}`;
  }

  // For non-account matchTypes, return the matchValue as is
  return condition.matchValue;
};