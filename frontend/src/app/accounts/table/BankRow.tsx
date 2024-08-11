import { Account, User } from "@/app/lib/definitions";

type BankRowProps = {
  bankName: string,
  accounts: Account[];
  user: User | null;
}

export default function BankRow({
  bankName,
  accounts,
  user
}: BankRowProps) {
  return (
    <div className="mb-6">
      <div className="grid grid-cols-2 gap-4 my-2">
        <div>
          {bankName}
          {user && (
            <div className="text-md text-gray-500">
              {user.name}
            </div>
          )}
        </div>
        <div className="text-md">
          {accounts.map(account => (
            <div
              key={account.id}
              className="my-1"
            >
              {account.name}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}