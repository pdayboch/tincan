import { fetchTransactionTrendOverTime } from "@/lib/api/transaction-trend-api";
import { TransactionTrendOverTime } from "@/lib/definitions";
import { dateToString } from "@/lib/helpers";
import { useEffect, useState } from "react";
import {
  Bar,
  BarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from "recharts";
import { format, parseISO } from "date-fns";
import { toZonedTime } from 'date-fns-tz';

interface OverTimeChartProps {
  startDate: Date;
  endDate: Date;
  type: string;
  groupBy: string;
}

export default function OverTimeChart({
  startDate,
  endDate,
  type,
  groupBy
}: OverTimeChartProps) {
  const [trendData, setTrendData] = useState<TransactionTrendOverTime>([]);

  // Fetch Transaction Trend Data
  useEffect(() => {
    fetchTransactionTrendOverTime(
      dateToString(startDate),
      dateToString(endDate),
      type,
      groupBy
    ).then(data => {
      setTrendData(data)
    })
      .catch(error => {
        console.error(error);
      })
  }, [startDate, endDate, type, groupBy]);

  const formatXAxisTick = (dateStr: string) => {
    const dateInUTC = parseISO(dateStr);
    const zonedDate = toZonedTime(dateInUTC, 'UTC');

    if (groupBy === "day") {
      return format(zonedDate, "MMM d"); // e.g., "Mar 1" or "Jun 20"
    } else if (groupBy === "month") {
      return format(zonedDate, "MMM"); // e.g., "Jan", "Feb", etc.
    }
    return dateStr;
  };

  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart
        data={trendData}
        margin={{ top: 20, right: 30, left: 10, bottom: 10 }}
      >
        <XAxis
          dataKey="date"
          tickFormatter={formatXAxisTick}
          interval={groupBy === "day" ? 3 : 0}
          padding={{ left: 20, right: 20 }}
        />
        <YAxis />
        <Tooltip />
        <Bar dataKey="amount" fill="#4F46E5" />
      </BarChart>
    </ResponsiveContainer>
  );
}