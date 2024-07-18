'use client'
import { Category } from '@/app/lib/definitions';
import React, { useState, useEffect, useRef } from 'react';

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
      className={`
        absolute
        w-auto
        min-w-full
        min-h-52
        overflow-y-auto
        ${isOpen ? 'bg-theme-drk-green border-2 shadow-lg z-50' : ''}
      `}
    >
      {!isOpen && (
        <button
          onClick={toggleDropdown}
          className="bg-transparent"
        >
          {currentCategory}
        </button>
      )}

      {isOpen && (
        <>
          <input
            type="text"
            placeholder="Search categories..."
            value={searchTerm}
            onChange={handleSearchChange}
            autoFocus
            className="w-full box-border p-2"
          />
          <div
            className="max-h-52 overflow-y-auto w-auto"
          >
            <ul
              className="list-none p-1 m-0"
            >
              {filteredCategories.map((category) => (
                <li key={category.id} className="pt-4">
                  <strong>{category.name}</strong>
                  <ul>
                    {category.subcategories.map((subcategory) => (
                      <li key={subcategory.id} className="p-2">
                        <button
                          onClick={() => handleSelection(subcategory.name)}
                        >
                          {subcategory.name}
                        </button>
                      </li>
                    ))}
                  </ul>
                </li>
              ))}
            </ul>
          </div>
        </>
      )}
    </div>
  );
}