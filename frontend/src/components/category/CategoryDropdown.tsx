'use client'
import React, { useState, useEffect, useRef } from 'react';
import { Category } from '@/lib/definitions';
import { ChevronDoubleDownIcon } from "@heroicons/react/24/outline";
import CategoryDropdownItem from './CategoryDropdownItem';

interface CategoryDropdownProps {
  categories: Category[];
  currentSubcategory: { id: number, name: string };
  onChange: (subcategory: { id: number, name: string }) => void;
};

export default function CategoryDropdown({
  categories,
  currentSubcategory,
  onChange
}: CategoryDropdownProps) {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [filteredCategories, setFilteredCategories] = useState<Category[]>([]);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Event listener to close the dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false)
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    }
  }, []);

  // Initially set filteredCategories to categories
  useEffect(() => {
    setFilteredCategories(categories)
  }, [categories])

  const toggleDropdown = () => setIsOpen(!isOpen)

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const term = event.target.value;
    setSearchTerm(term);

    if (term.trim() === '') {
      setFilteredCategories(categories);
    } else {
      const lowerCaseTerm = term.toLowerCase();
      const filtered = categories.map((category) => ({
        ...category,
        subcategories: category.subcategories.filter((subcategory) =>
          subcategory.name.toLowerCase().includes(lowerCaseTerm)
        ),
      })).filter(category => category.subcategories.length > 0);

      setFilteredCategories(filtered);
    }
  };

  const handleSelection = async (subcategory: { id: number, name: string }) => {
    onChange(subcategory);
    toggleDropdown();
  }

  return (
    <div
      ref={dropdownRef}
      className="relative w-full"
    >
      <div
        className="flex items-center justify-left h-full cursor-pointer"
        onClick={toggleDropdown}
        title="Select a category"
      >
        {currentSubcategory.name}
        {!isOpen && <ChevronDoubleDownIcon className="w-4 h-4 ml-2 text-gray-500" />}
      </div>

      {/* The expanded dropdown */}
      {isOpen && (
        <div className="w-full bg-slate-300 z-3 border-3">
          <input
            type="text"
            placeholder="Search categories..."
            value={searchTerm}
            onChange={handleSearchChange}
            autoFocus
            className="w-full box-border p-2"
          />
          <div className="max-h-52 overflow-y-auto w-auto px-2">
            {filteredCategories.map((category) => (
              <CategoryDropdownItem
                key={category.id}
                category={category}
                onClick={handleSelection}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}