import { useState } from "react";
import clsx from "clsx";
import { Account, AccountUpdate } from "@/app/lib/definitions";
import AccountModal from "../AccountModal";

type AccountSubRowProps = {
  account: Account;
  onUpdateAccount: (accountId: number, data: AccountUpdate) => void;
  onDeleteAccount: (accountId: number) => void;
};

export default function AccountSubRow({
  account,
  onUpdateAccount,
  onDeleteAccount
}: AccountSubRowProps) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleButtonClick = () => {
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };

  return (
    <div className="flex items-center">
      <button
        onClick={handleButtonClick}
        className={clsx("my-1 px-3 py-1 border rounded-full hover:bg-gray-100",
          account.active ? "border-gray-300 text-gray-700" : "border-gray-400 text-gray-500 bg-gray-200")}
      >
        {account.name}
      </button>
      {!account.active && (
        <span className="ml-2 text-gray-500">Inactive</span>
      )}
      {isModalOpen && (
        <AccountModal
          account={account}
          onClose={handleCloseModal}
          onUpdateAccount={onUpdateAccount}
          onDeleteAccount={onDeleteAccount}
        />
      )}
    </div>
  );
}