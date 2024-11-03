import { Account } from "./definitions";

// Helper function to format amount as dollar value
export const formatCurrency = (amount: number) => {
  const formattedAmount = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  }).format(Math.abs(amount));

  return amount < 0 ? `-${formattedAmount}` : `${formattedAmount}`;
};

export const formatDate = (dateString: string) => {
  const [year, month, day] = dateString.split('-');
  return `${month}-${day}-${year}`;
};

export function dateToString(date: Date): string {
  const year = date.getFullYear();
  // Months are 0-indexed, so add 1
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

export const formatAccountLabel = (
  account: Account | undefined,
  withCustodian: boolean = true
): string => {
  if (!account) return '';

  const custodian = withCustodian ? `${account.user.name} ` : '';

  if (account.nickname) return `${custodian}${account.nickname}`;
  if (account.bankName) return `${custodian}${account.bankName} ${account.name}`;
  return `${custodian}${account.name}`;
};