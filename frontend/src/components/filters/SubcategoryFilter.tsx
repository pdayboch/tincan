import { Category } from "@/lib/definitions";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import Select, { MultiValue } from 'react-select';

interface SubcategoryFilterProps {
  categories: Category[]
}

type OptionType = {
  id: number,
  value: number,
  label: string
};

type GroupedOptionType = {
  id: number,
  label: string,
  options: OptionType[]
};

export default function SubcategoryFilter({
  categories
}: SubcategoryFilterProps) {
  const [selectedSubcategories, setSelectedSubcategories] = useState<OptionType[]>([]);

  const categoryOptions: GroupedOptionType[] = categories.map(
    category => ({
      id: category.id,
      label: category.name,
      options: category.subcategories.map(subcategory => ({
        id: subcategory.id,
        value: subcategory.id,
        label: subcategory.name,
      })),
    })
  );

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  useEffect(() => {
    const subcategoriesParam = searchParams.getAll('subcategories[]');
    const newSelectedSubcategories = categoryOptions.flatMap(
      group =>
        group.options.filter(
          option => subcategoriesParam.includes(String(option.value))
        )
    );

    setSelectedSubcategories(newSelectedSubcategories);
  }, [searchParams]);

  const handleSelectionChange = (
    selectedOptions: MultiValue<OptionType>
  ) => {
    const params = new URLSearchParams(searchParams);
    // Reset pagination to page 1 since accounts are changing.
    params.delete('startingAfter');
    params.delete('endingBefore');

    // Update subcategories[] param
    if (selectedOptions.length > 0) {
      const selectedIds = selectedOptions.map(option =>
        String(option.value)
      );
      params.delete('subcategories[]');
      selectedIds.forEach(id => params.append('subcategories[]', id))
    } else {
      params.delete('subcategories[]');
    }

    replace(`${pathname}?${params.toString()}`)
  };

  return (
    <Select
      instanceId="subcategory-filter-select"
      options={categoryOptions}
      isMulti
      isSearchable
      placeholder="All subcategories"
      onChange={handleSelectionChange}
      value={selectedSubcategories}
    />
  );
}