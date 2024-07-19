'use client'
import { Category } from '@/app/lib/definitions';
import React, { useState, useEffect, useRef } from 'react';
import CategoryDropdownItem from './CategoryDropdownItem';
import clsx from 'clsx';

interface CategoryDropdownProps {
  categories: Category[];
  currentCategory: string;
  onChange: (subcategoryName: string) => void;
};

export default function CategoryDropdown({
  categories,
  currentCategory,
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
    return() => {
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

  const handleSelection = async (subcategory_name: string) => {
    onChange(subcategory_name);
    toggleDropdown();
  }

  return (
    <div
      ref={dropdownRef}
      className={clsx('relative', 'w-full')}
    >
      <button onClick={toggleDropdown}>
        {currentCategory}
      </button>
      {/* The expanded dropdown */}
      {isOpen && (
        <div className="absolute w-full bg-slate-300 z-3 border-3">
          <input
            type="text"
            placeholder="Search categories..."
            value={searchTerm}
            onChange={handleSearchChange}
            autoFocus
            className="w-full box-border p-2"
          />
          <div className="max-h-52 overflow-y-auto w-auto">
            <ul className="list-none p-1">
              {filteredCategories.map((category) => (
                <CategoryDropdownItem
                  category={category}
                  onClick={handleSelection}
                />
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}