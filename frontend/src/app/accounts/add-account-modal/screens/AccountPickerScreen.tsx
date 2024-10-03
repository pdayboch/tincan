import React, { useEffect, useState } from 'react';
import Image from 'next/image';
import { SupportedAccount } from '@/lib/definitions';
import Search from '@/components/Search';

interface AccountPickerScreenProps {
  supportedAccounts: SupportedAccount[]
  searchQuery: string,
  setSearchQuery: (query: string) => void;
  onAccountSelect: (account: SupportedAccount) => void;
}

export default function AccountPickerScreen({
  supportedAccounts,
  searchQuery,
  setSearchQuery,
  onAccountSelect
}: AccountPickerScreenProps) {
  const [filteredAccounts, setFilteredAccounts] = useState<SupportedAccount[]>([]);

  // Filter accounts whenever supportedAccounts or searchQuery changes
  useEffect(() => {
    const query = searchQuery.toLowerCase();
    const filtered = supportedAccounts.filter((account) =>
      `${account.bankName} ${account.accountName}`.toLowerCase().includes(query)
    );
    setFilteredAccounts(filtered);
  }, [searchQuery, supportedAccounts]);

  const getImageUrl = (accountPovider: string) => {
    return `/account_providers/${accountPovider}.png`;
  }

  return (
    <>
      <p className='text-xl'>Select an account</p>

      {/* Search bar */}
      <div className='flex mx-6 mt-5 mb-4'>
        <Search
          placeholder='Search accounts'
          value={searchQuery}
          onSearch={setSearchQuery}
        />
        <button
          onClick={(e) => setSearchQuery('')}
          className='ml-2 p-2 rounded bg-blue-500 text-white hover:bg-blue-600'
        >
          Clear
        </button>
      </div>

      {/* Scrollable account section */}
      <div className='flex-1 overflow-y-auto p-2'>
        <div className='grid grid-cols-3 gap-4'>
          {filteredAccounts.map((account) => (
            <div
              key={account.accountProvider}
              className='flex flex-col items-center justify-center \
                cursor-pointer text-center transform transition-transform \
                duration-100 hover:scale-105 hover:shadow-lg'
              onClick={() => onAccountSelect(account)}
            >
              <div className='relative'>
                <div className='w-24 h-24 bg-gray-200 rounded-full \
                  flex items-center justify-center'>
                  <Image
                    src={getImageUrl(account.accountProvider)}
                    width={96}
                    height={96}
                    alt={`${account.bankName} ${account.accountName}`}
                    className='object-contain rounded-lg'
                    style={{ height: '96px', width: 'auto' }}
                  />
                </div>
              </div>
              <span className='mt-2'>
                {account.bankName}<br />{account.accountName}
              </span>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}