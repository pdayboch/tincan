import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { useDebouncedCallback } from 'use-debounce';

interface SearchProps {
  placeholder: string;
  value: string | undefined
  onSearch: (term: string) => void;
}

export default function Search({
  placeholder,
  value,
  onSearch
}: SearchProps) {
  const handleInputChange = useDebouncedCallback((term: string) => {
    onSearch(term)
  }, 300);

  return (
    <div className="relative flex flex-1 flex-shrink-0 h-full">
      <label htmlFor="search" className="sr-only">
        Search
      </label>
      <input
        className="peer block w-full rounded-md border border-gray-200 py-[9px] pl-10 text-sm outline-2 placeholder:text-gray-500"
        placeholder={placeholder}
        onChange={(e) => handleInputChange(e.target.value)}
        defaultValue={value}
      />
      <MagnifyingGlassIcon
        className="absolute left-3 top-1/2 w-[18px] -translate-y-1/2 text-gray-500 peer-focus:text-gray-900"
      />
    </div>
  );
}
