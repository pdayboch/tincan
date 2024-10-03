import { getBaseApiUrl } from "@/utils/api-utils";
import { CategoryResponse } from "../definitions";

export async function fetchCategories(): Promise<CategoryResponse> {
  const url = `${getBaseApiUrl()}/categories`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching categories: ${response.status}`);
  }
  const data: CategoryResponse = await response.json();
  return data;
}