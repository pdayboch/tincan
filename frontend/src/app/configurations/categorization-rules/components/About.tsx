import { useState } from 'react';
import clsx from 'clsx';
import { ChevronDownIcon, ChevronUpIcon } from '@heroicons/react/24/solid';


export default function About() {
  const [isOpen, setIsOpen] = useState(false);

  const toggleDropdown = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className="w-3/4 max-w-xl mx-auto">
      <button
        className="flex items-center justify-between \
                    h-10 w-full p-4 bg-gray-100 \
                    rounded-lg shadow hover:bg-gray-50 \
                    focus:outline-none focus:ring-2 focus:ring-blue-500"
        onClick={toggleDropdown}
      >
        <span className="text-lg">
          What are auto-categorization rules?
        </span>
        {isOpen ? (
          <ChevronUpIcon className="w-5 h-5 text-gray-600" />
        ) : (
          <ChevronDownIcon className="w-5 h-5 text-gray-600" />
        )}
      </button>

      <div className={clsx(
        'mt-2 p-4 bg-gray-50 border rounded-md text-left \
          transition-all duration-300 ease-in-out',
        {
          'max-h-[500px] opacity-100': isOpen,
          'h-0 opacity-0 overflow-hidden': !isOpen
        })}
      >
        <p>
          Auto-categorization rules allow you to automatically classify transactions based on specific conditions.
          By setting up rules, you can streamline your budgeting and transaction management by ensuring that
          certain types of transactions are automatically categorized under the appropriate categories.
        </p>
        <p className="mt-2">
          These rules will only apply to uncategorized transactions. Auto-categorization rules will never change
          categorized transactions.
        </p>
      </div>
    </div>
  );
}