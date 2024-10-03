import { useState } from 'react';
import clsx from 'clsx';
import { Account, AccountUpdate } from '@/lib/definitions';
import AccountModal from '../update-account-modal/UpdateAccountModal';

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
  const [isUpdateModalOpen, setIsUpdateModalOpen] = useState(false);

  const handleButtonClick = () => {
    setIsUpdateModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsUpdateModalOpen(false);
  };

  return (
    <div className='flex items-center'>
      <button
        onClick={handleButtonClick}
        className={clsx(
          'my-1 px-3 py-1 border rounded-full hover:bg-slate-100',
          account.active ?
            'border-gray-300 text-gray-700' :
            'border-gray-400 text-gray-500 bg-gray-200'
        )}
      >
        {account.name}
      </button>
      {!account.active && (
        <span className='ml-2 text-gray-500'>Inactive</span>
      )}
      {isUpdateModalOpen && (
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