import { Category } from '@/app/lib/definitions';

interface CategoryDropdownItemProps {
  category: Category;
  onClick: (subcategoryName: string) => void;
};

export default function CategoryDropdownItem({
  category,
  onClick
}: CategoryDropdownItemProps) {

  return (
    <div key={category.id} className="pt-2">
      <strong>{category.name}</strong>
      {category.subcategories.map((subcategory) => (
        <div
          key={subcategory.id}
          className="p-2 rounded-md hover:bg-slate-100 cursor-pointer"
          onClick={() => onClick(subcategory.name)}>
          {subcategory.name}
        </div>
      ))}
    </div>
  );
}