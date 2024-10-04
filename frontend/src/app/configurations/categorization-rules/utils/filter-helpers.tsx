import { CategorizationCondition, CategorizationRule } from "@/lib/definitions";

// Filter rules by searchString
export const filterBySearchString = (
  rules: CategorizationRule[],
  searchString: string
): CategorizationRule[] => {
  if (!searchString) return rules;

  const scoredRules = rules
    .map(rule => ({
      rule,
      matchScore: getRuleHighestMatchScore(rule, searchString)
    }))
    .filter(({ matchScore }) => matchScore > 0)
    .sort((a, b) => b.matchScore - a.matchScore);

  return scoredRules.map(({ rule }) => rule);
};

// Filter rules by accounts array
export const filterByAccounts = (
  rules: CategorizationRule[],
  accounts: string[]
): CategorizationRule[] => {
  if (accounts.length === 0) return rules;

  return rules.filter((rule) =>
    rule.conditions.some(
      (condition: CategorizationCondition) =>
        accounts.includes(condition.matchValue) &&
        condition.transactionField === 'account'
    )
  );
};

// Filter rules by subcategories array
export const filterBySubcategories = (
  rules: CategorizationRule[],
  subcategories: string[]
): CategorizationRule[] => {
  if (subcategories.length === 0) return rules;

  return rules.filter((rule) =>
    subcategories.includes(rule.subcategory.id.toString())
  );
};

const calculateMatchScore = (
  matchValue: string,
  searchString: string
): number => {
  // Exact match (case-sensitive)
  if (matchValue === searchString) return 1;

  // Substring match (case-sensitive)
  if (matchValue.includes(searchString)) return 0.9;

  const matchValueWithoutNonWord = matchValue.replace(/[^\w]/g, '');
  const searchStringWithoutNonWord = searchString.replace(/[^\w]/g, '');

  // Exact match (case-sensitive, ignoring non-word characters)
  if (matchValueWithoutNonWord === searchStringWithoutNonWord) return 0.8;
  // Substring match (case-sensitive, ignoring non-word characters)
  if (matchValueWithoutNonWord.includes(searchStringWithoutNonWord)) return 0.7;

  const lowerMatchValue = matchValue.toLowerCase();
  const lowerSearchString = searchString.toLowerCase();

  // Exact match (case-insensitive)
  if (lowerMatchValue === lowerSearchString) return 0.6;
  // Substring match (case-insensitive)
  if (lowerMatchValue.includes(lowerSearchString)) return 0.5;

  // Substring match (case-insensitive, ignoring non-word characters)
  if (matchValueWithoutNonWord
    .toLowerCase()
    .includes(searchStringWithoutNonWord
      .toLocaleLowerCase()
    )
  ) return 0.4;

  return 0;
}

const getRuleHighestMatchScore = (
  rule: CategorizationRule,
  searchString: string
): number => {
  const searchStringApplicableFields = ['description', 'amount', 'date'];
  let highestMatchScore = 0;

  rule.conditions.forEach((condition: CategorizationCondition) => {
    if (searchStringApplicableFields.includes(condition.transactionField)) {
      const matchScore = calculateMatchScore(condition.matchValue, searchString);
      if (matchScore > highestMatchScore) highestMatchScore = matchScore;
    }
  });

  return highestMatchScore;
}
