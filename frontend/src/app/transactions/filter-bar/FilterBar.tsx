import { Account, User } from "@/app/lib/definitions";
import AccountSelector from "./AccountSelector";
import UserSelector from "./UserSelector";

type FilterBarProps = {
  accounts: Account[];
  users: User[];
};

export default function FilterBar({accounts, users}: FilterBarProps) {
  return (
    <div className="flex">
      <AccountSelector accounts={accounts} />
      <UserSelector users={users} />
    </div>
  )
}