import { Account } from "@/app/lib/definitions";

type AccountModalProps = {
  account: Account;
  onClose: () => void;
};

export default function AccountModal({
  account,
  onClose
}: AccountModalProps) {
  const handleDeleteClick = () => {
    const accountDisplayName = account.bankName ? `${account.bankName} ${account.name}` : account.name;
    const confirmation = window.confirm(
      `Are you sure you want to delete ${accountDisplayName}? This will delete all associated transactions. To keep the transactions but disable the account, click cancel and disable the account from the previous screen.`
    );
    if (confirmation) {
      // Handle the deletion logic here
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex justify-center items-center">
      <div className="bg-white p-4 rounded shadow-lg">
        <h2 className="text-xl mb-4">Account Details</h2>
        <p><strong>Bank:</strong> {account.bankName || ""}</p>
        <p><strong>Name:</strong> {account.name}</p>
        <p><strong>Account Type:</strong> {account.accountType}</p>
        <p><strong>Statement Directory:</strong> {account.statementDirectory}</p>
        <div className="mt-4 flex justify-end">
          <button onClick={handleDeleteClick} className="bg-red-500 text-white px-4 py-2 rounded mr-2">
            Delete
          </button>
          <button onClick={onClose} className="bg-gray-500 text-white px-4 py-2 rounded">Close</button>
        </div>
      </div>
    </div>
  );
}