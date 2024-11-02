import { Category } from "@/lib/definitions";
import Select, { SingleValue } from 'react-select';

interface SubcategorySelectorProps {
  categories: Category[],
  currentSubcategory: { id: number, name: string } | null;
  onChange: (subcategory: { id: number, name: string }) => void;
}

type OptionType = {
  value: number,
  label: string,
};

type GroupedOptionType = {
  label: string,
  options: OptionType[]
};

export default function SubcategorySelector({
  categories,
  currentSubcategory,
  onChange
}: SubcategorySelectorProps) {
  const categoryOptions: GroupedOptionType[] = categories.map(
    category => ({
      label: category.name,
      options: category.subcategories.map(subcategory => ({
        value: subcategory.id,
        label: subcategory.name,
      })),
    })
  );

  // Build the currentSubcategory option
  const selectedOption: OptionType | null = currentSubcategory
    ? {
      value: currentSubcategory.id,
      label: currentSubcategory.name
    }
    : null;

  const handleSelectionChange = (option: SingleValue<OptionType>) => {
    if (option) onChange({ id: option.value, name: option.label });
  };

  return (
    <Select
      instanceId="subcategory-selector"
      options={categoryOptions}
      isSearchable
      placeholder="Select subcategory"
      onChange={handleSelectionChange}
      value={selectedOption}
    />
  );
}