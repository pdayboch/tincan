import { Account, User } from "@/app/lib/definitions";
import AccountSelector from "./AccountSelector";
import UserSelector from "./UserSelector";
import { Inter } from 'next/font/google';
import clsx from "clsx";
const font = Inter({ weight:["400"], subsets:['latin'] });

type FilterBarProps = {
  accounts: Account[];
  users: User[];
};

export default function FilterBar({accounts, users}: FilterBarProps) {
  return (
    <div className="flex flex-col items-center h-full w-full">
      <span className={clsx("text-2xl", font.className)}>Filters</span>
      <AccountSelector accounts={accounts} users={users} />
      <UserSelector users={users} />
    </div>
  )
}