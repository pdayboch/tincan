import { getBaseApiUrl } from "@/utils/api-utils";
import { CategorizationCondition, CategorizationConditionUpdate } from "../definitions";

export async function createCategorizationCondition(
  ruleId: number,
  newCondition: CategorizationConditionUpdate
): Promise<CategorizationCondition> {
  const url = `${getBaseApiUrl()}/categorization/conditions`;

  const requestBody = {
    ...newCondition,
    categorizationRuleId: ruleId
  }

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(requestBody)
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error creating categorization condition: ${errorMessage}`)
  }
  const data: CategorizationCondition = await response.json();
  return data;
}

export async function updateCategorizationCondition(
  id: number,
  updates: CategorizationConditionUpdate
): Promise<CategorizationCondition> {
  const url = `${getBaseApiUrl()}/categorization/conditions/${id}`;
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error updating categorization condition: ${errorMessage}`)
  }
  const data: CategorizationCondition = await response.json();
  return data;
}

export async function deleteCategorizationCondition(
  id: number,
): Promise<boolean> {
  const url = `${getBaseApiUrl()}/categorization/conditions/${id}`;
  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json'
    },
  });
  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`Error deleting categorization condition: ${errorMessage}`)
  }
  return true;
}