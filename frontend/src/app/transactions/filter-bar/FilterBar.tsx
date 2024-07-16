import { Account, User } from "@/app/lib/definitions";
import AccountSelector from "./AccountSelector";
import UserSelector from "./UserSelector";

type FilterBarProps = {
  accounts: Account[];
  users: User[];
};

export default function FilterBar({accounts, users}: FilterBarProps) {
  return (
    <div className="flex gap-2 h-full">
      <AccountSelector accounts={accounts} users={users} />
      <UserSelector users={users} />
    </div>
  )
}