import { useState } from "react";
import { Account } from "@/app/lib/definitions";
import AccountModal from "../AccountModal";

type AccountSubRowProps = {
  account: Account;
};

export default function AccountSubRow({ account }: AccountSubRowProps) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleButtonClick = () => {
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };

  return (
    <div>
      <button
        onClick={handleButtonClick}
        className="my-1 px-3 py-1 border border-gray-300 text-gray-700 rounded-full hover:bg-gray-100"
      >
        {account.name}
      </button>
      {isModalOpen && (
        <AccountModal account={account} onClose={handleCloseModal} />
      )}
    </div>
  );
}