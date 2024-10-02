import clsx from 'clsx';
import React from 'react';

export type FilterItemType = {
  id: string,
  label: string,
  sublabel: string | null
}

type DropdownItemProps = {
  title: string,
  subtitle: string,
  isSelected: boolean
  onClick: (event: React.MouseEvent<HTMLDivElement>) => void;
};

export default function DropdownItem({ title, subtitle, isSelected, onClick }: DropdownItemProps) {
  return (
    <div
      className={clsx(
        'flex items-center text-md p-3 b-2 rounded-md',
        isSelected ? 'bg-slate-200' : 'bg-white',
        !isSelected && 'hover:bg-slate-100'
      )}
      onClick={onClick}
    >
      {title}
      <span className="text-sm text-gray-500 ml-2 mt-1">
        {subtitle}
      </span>
    </div>
  );
}