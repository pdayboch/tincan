import clsx from "clsx";

export const amountClass = (amount: number): string => {
  return clsx({
    'text-green-600': amount >= 0,
    'text-red-600': amount < 0,
  })
};