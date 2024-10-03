import { getBaseApiUrl } from "@/utils/api-utils";
import { CategorizationRule, CategorizationRuleUpdate } from "../definitions";

export async function fetchCategorizationRules(): Promise<CategorizationRule[]> {
  const url = `${getBaseApiUrl()}/categorization/rules`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching categorization rules: ${response.status}`);
  }
  const data: CategorizationRule[] = await response.json();
  return data;
}

export async function createCategorizationRule(
  newRule: CategorizationRuleUpdate
): Promise<CategorizationRule> {
  const url = `${getBaseApiUrl()}/categorization/rules`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(newRule)
  });

  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error creating categorization rule: ${errorMessage}`)
  }
  const data: CategorizationRule = await response.json();
  return data;
}


export async function updateCategorizationRule(
  id: number,
  update: CategorizationRuleUpdate
): Promise<CategorizationRule> {
  const url = `${getBaseApiUrl()}/categorization/rules/${id}`;
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(update)
  });

  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error updating categorization rule: ${errorMessage}`)
  }
  const data: CategorizationRule = await response.json();
  return data;
}

export async function deleteCategorizationRule(
  id: number,
): Promise<boolean> {
  const url = `${getBaseApiUrl()}/categorization/rules/${id}`;
  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json'
    },
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error deleting categorization rule: ${errorMessage}`)
  }
  return true;
}
