import { getBaseApiUrl } from "@/utils/api-utils";
import { User } from "../definitions";

export async function fetchUsers(): Promise<User[]> {
  const url = `${getBaseApiUrl()}/users`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching users: ${response.status}`);
  }
  const data: User[] = await response.json();
  return data;
}