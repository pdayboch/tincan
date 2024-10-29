export function getStartAndEndDates(
  timeRange: string
): { startDate: Date; endDate: Date } {
  const today = new Date();
  let startDate = new Date(today);
  let endDate = new Date(today);

  switch (timeRange) {
    case "monthToDate":
      // Start at the first of the current month
      startDate.setDate(1);
      break;

    case "lastMonth":
      // First of last month
      startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
      // Last day of last month
      endDate = new Date(today.getFullYear(), today.getMonth(), 0);
      break;

    case "last3Months":
      // First day 3 months ago
      startDate = new Date(today.getFullYear(), today.getMonth() - 3, 1);
      // Last day of last month
      endDate = new Date(today.getFullYear(), today.getMonth(), 0);
      break;

    case "last6Months":
      // First day 6 months ago
      startDate = new Date(today.getFullYear(), today.getMonth() - 6, 1);
      // Last day of last month
      endDate = new Date(today.getFullYear(), today.getMonth(), 0);
      break;

    case "yearToDate":
      // Start of the current year
      startDate = new Date(today.getFullYear(), 0, 1);
      break;

    case "lastYear":
      // First day of last year
      startDate = new Date(today.getFullYear() - 1, 0, 1);
      // Last day of last year
      endDate = new Date(today.getFullYear() - 1, 11, 31);
      break;

    default:
      throw new Error(`Unknown time range: ${timeRange}`);
  }

  return { startDate, endDate };
}