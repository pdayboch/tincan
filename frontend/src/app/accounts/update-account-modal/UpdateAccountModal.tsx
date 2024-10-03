import { useEffect, useState } from 'react';
import { ThreeDots } from 'react-loader-spinner';
import clsx from 'clsx';
import { QuestionMarkCircleIcon, TrashIcon, XMarkIcon } from '@heroicons/react/24/solid';
import { Account, AccountUpdate } from '@/lib/definitions';

type AccountModalProps = {
  account: Account;
  onClose: () => void;
  onUpdateAccount: (accountId: number, data: AccountUpdate) => void;
  onDeleteAccount: (accountId: number) => void;
};

export default function AccountModal({
  account,
  onClose,
  onUpdateAccount,
  onDeleteAccount
}: AccountModalProps) {
  const [statementDirectory, setStatementDirectory] = useState(account.statementDirectory);
  const [isStatementDirectorySaved, setIsStatementDirectorySaved] = useState(true);
  const [isStatementDirectoryLoading, setIsStatementDirectoryLoading] = useState(false);
  const [isActive, setIsActive] = useState(account.active);

  useEffect(() => {
    const isSaved = statementDirectory === account.statementDirectory;
    setIsStatementDirectorySaved(isSaved);
  }, [statementDirectory, account.statementDirectory]);

  const handleStatementDirectoryChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setStatementDirectory(e.target.value);
  };

  const handleStatementDirectoryKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter' && !isStatementDirectorySaved) {
      handleSaveStatementDirectory();
    }
  };

  // Event handler for when statement directory is saved:
  const handleSaveStatementDirectory = async () => {
    setIsStatementDirectoryLoading(true);
    await onUpdateAccount(account.id, { statementDirectory: statementDirectory });
    setIsStatementDirectoryLoading(false);
    setIsStatementDirectorySaved(true);
  };

  // Event handler for when active status is toggled:
  const handleToggleActive = async () => {
    const newActiveStatus = !isActive;
    setIsActive(newActiveStatus);
    await onUpdateAccount(account.id, { active: newActiveStatus });
  };

  // Event handler for when delete button is clicked:
  const handleDeleteClick = () => {
    const accountDisplayName = account.bankName ? `${account.bankName} ${account.name}` : account.name;
    const confirmation = window.confirm(
      `Are you sure you want to delete ${accountDisplayName}?\n\nThis will delete all associated transactions. To keep the transactions but disable the account, click cancel and disable the account from the previous screen.`
    );
    if (confirmation) {
      onDeleteAccount(account.id);
      onClose();
    }
  };

  const handleCloseClick = () => {
    if (!isStatementDirectorySaved) {
      const confirmation = window.confirm('You have unsaved changes. Are you sure you want to discard them?');
      if (!confirmation) return;
    }
    onClose();
  }

  return (
    <div className='fixed inset-0 bg-gray-600 bg-opacity-50 flex justify-center items-center'>
      <div className='bg-white p-4 rounded shadow-lg flex-none w-[550px]'>
        <h2 className='text-2xl mb-4'>Account Details</h2>

        {/* Account Name */}
        <p className='text-xl'>{account.bankName || ''} {account.name}</p>

        {/* Account Type */}
        <div className='mt-5 flex'>
          <label className='mb-1 pr-2'>Account Type</label>
          <select value={account.accountType} disabled className='border p-1 rounded-md w-auto'>
            <option value={account.accountType}>{account.accountType}</option>
          </select>
        </div>

        {/* Statement Directory */}
        <div className='mt-5 flex items-center'>
          <label className='mb-1 pr-2'>Statement Directory</label>
          <input
            type='text'
            value={statementDirectory}
            onChange={handleStatementDirectoryChange}
            onKeyDown={handleStatementDirectoryKeyDown}
            className={clsx(
              'border p-1 flex-grow rounded-md',
              isStatementDirectorySaved ?
                'border-gray-300' :
                'border-red-500'
            )}
            style={{ outline: 'none' }}
          />
          <button
            onClick={handleSaveStatementDirectory}
            className={clsx(
              'ml-2 px-1 py-2 w-[45px] h-[30px]',
              'text-white text-sm rounded',
              'flex items-center justify-center',
              isStatementDirectorySaved || isStatementDirectoryLoading ?
                'bg-gray-400' :
                'bg-blue-500'
            )}
            disabled={isStatementDirectorySaved || isStatementDirectoryLoading}
          >
            {isStatementDirectoryLoading ? (
              <div className='flex items-center justify-center w-full h-full'>
                <ThreeDots
                  height='15'
                  width='15'
                  color='#ffffff'
                  ariaLabel='loading'
                />
              </div>
            ) : isStatementDirectorySaved ? (
              'Saved'
            ) : (
              'Save'
            )}
          </button>
        </div>

        {/* Active Toggle*/}
        <div className='mt-5 flex items-center'>
          <label className='mb-1 pr-2'>Active</label>
          <div className='mb-1 relative group'>
            <QuestionMarkCircleIcon className='w-5 h-5 text-gray-500' />
            <div className='absolute bottom-full left-1/2 \
              transform -translate-x-1/2 mb-2 w-80 p-2 \
              bg-gray-700 text-white text-xs rounded \
              opacity-0 group-hover:opacity-100 transition-opacity'
            >
              Marking an account as inactive will stop the parser
              from processing statements in this directory. You will
              not receive notifications for missing monthly statements.
            </div>
          </div>
          <div
            className='ml-3 flex items-center cursor-pointer'
            onClick={handleToggleActive}
          >
            <div
              className={clsx(
                'px-4 py-1 rounded-l',
                isActive ?
                  'bg-green-500 text-white' :
                  'bg-gray-300 text-gray-500'
              )}
            >
              Active
            </div>
            <div
              className={clsx(
                'px-4 py-1 rounded-r',
                !isActive ?
                  'bg-red-500 text-white' :
                  'bg-gray-300 text-gray-500'
              )}
            >
              Inactive
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className='mt-20 flex justify-end'>
          <button
            className='bg-red-400 hover:bg-red-500 text-white px-4 py-2 \
              rounded-lg mr-3 shadow-sm flex items-center space-x-2 \
              transition duration-300 ease-in-out'
            onClick={handleDeleteClick}
          >
            <TrashIcon className='h-5 w-5' />
            <span>Delete</span>
          </button>

          <button
            className='bg-gray-400 hover:bg-gray-500 text-white px-4 py-2 \
              rounded-lg shadow-sm flex items-center space-x-2 \
              transition duration-300 ease-in-out'
            onClick={handleCloseClick}
          >
            <XMarkIcon className='h-5 w-5' />
            <span>Close</span>
          </button>
        </div>
      </div>
    </div>
  );
}