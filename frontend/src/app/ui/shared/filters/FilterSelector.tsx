import React, { useEffect, useRef, useState } from 'react';
import FilterItem, { FilterItemType } from './FilterItem';

type FilterSelectorProps = {
  title: string;
  items: FilterItemType[];
  selectedItems: string[];
  onItemClick: (itemId: string) => void;
};

export default function FilterSelector({
  title,
  items,
  selectedItems,
  onItemClick
}: FilterSelectorProps) {
  // State to control the visibility of the dropdown
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  // Toggle the dropdown open/close
  const toggleDropdown = () => setIsDropdownOpen(!isDropdownOpen);

  // Ref for the Selector component
  const selectorRef = useRef<HTMLDivElement>(null);

  // Event handler for closing the dropdown if clicked outside
  const handleClickOutside = (event: MouseEvent) => {
    if (selectorRef.current &&
      !selectorRef.current.contains(event.target as Node)) {
      setIsDropdownOpen(false);
    }
  }

  // Add event listener on component mounts
  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      // Remove event listener when the component unmounts
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [])

  return (
    <div className="h-auto w-full my-1" ref={selectorRef}>
      <button
        type="button"
        className="w-full h-10 py-0 px-2 rounded \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner \
        border border-gray-300"
        onClick={toggleDropdown}
      >
        {title}
      </button>

      {isDropdownOpen && (
        <div className="w-full h-auto mt-1 max-h-96 overflow-y-auto rounded-md bg-white shadow-lg">
          <hr className="my-1" />
          <FilterItem
            key={0}
            title="All"
            subtitle={items.length.toString()}
            isSelected={selectedItems.length === 0}
            onClick={() => onItemClick("0")}
          />
          <hr className="my-1" />
          {items.map((item) => {
            return (
              <FilterItem
                key={item.id}
                title={item.label}
                subtitle={item.sublabel ? item.sublabel : ""}
                isSelected={selectedItems.includes(item.id)}
                onClick={() => onItemClick(item.id)}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}