import { getBaseApiUrl } from "@/utils/api-utils";
import { TransactionTrendOverTime } from "../definitions";

export async function fetchTransactionTrendOverTime(
  startDate: string,
  endDate: string,
  type: string,
  groupBy: string
): Promise<TransactionTrendOverTime> {
  const params = new URLSearchParams({
    startDate,
    endDate,
    type,
    groupBy
  });

  const url = `${getBaseApiUrl()}/trends/overTime?${params.toString()}`;

  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching trends over time: ${response.status}`);
  }
  const data: TransactionTrendOverTime = await response.json();
  return data;
}
