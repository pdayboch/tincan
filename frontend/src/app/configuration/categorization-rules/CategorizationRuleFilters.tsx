import { Account, Category, FilterItemType, Subcategory, User } from "@/app/lib/definitions";
import FilterSelector from "@/app/ui/shared/filters/FilterSelector";
import { usePathname, useRouter, useSearchParams } from "next/navigation";

type CategorizationRuleFiltersProps = {
  categories: Category[];
  accounts: Account[];
  users: User[];
};

export default function AccountFilters({
  categories, accounts, users
}: CategorizationRuleFiltersProps) {
  const subcategories: Subcategory[] = categories.flatMap((category) => {
    return category.subcategories
  });

  const getUser = (userId: number) => {
    return users.find(
      (user) => user.id === userId);
  };

  const searchParams = useSearchParams();
  const pathname = usePathname();
  const { replace } = useRouter();

  const handleSubcategoryClick = (id: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);

    let selectedSubcategories = params.getAll('subcategories[]');
    if (id === "0") {
      // if the value is 0, All was selected, so remove filter.
      params.delete('subcategories[]');
    } else {
      if (!selectedSubcategories.includes(id)) {
        // Add value to selected categories.
        params.append('subcategories[]', id);
      } else {
        // Remove value from selected categories.
        selectedSubcategories = selectedSubcategories
          .filter(item => item !== id);
        params.delete('subcategories[]');
        selectedSubcategories.forEach(subcategory => {
          params.append('subcategories[]', subcategory);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  const handleAccountClick = (id: string) => {
    // Clone the current search params
    const params = new URLSearchParams(searchParams);

    let selectedAccounts = params.getAll('accounts[]');
    if (id === "0") {
      params.delete('accounts[]');
    } else {
      if (!selectedAccounts.includes(id)) {
        // Add value to selected accounts.
        params.append('accounts[]', id);
      } else {
        // Remove value from selected accounts.
        selectedAccounts = selectedAccounts
          .filter(accountId => accountId !== id);
        params.delete('accounts[]');
        selectedAccounts.forEach(accountId => {
          params.append('accounts[]', accountId);
        });
      }
    }

    replace(`${pathname}?${params.toString()}`)
  };

  // Get the selected items from the URL
  const selectedSubcategories = searchParams.getAll('subcategories[]');

  // Get the selected accounts from the URL
  const selectedAccounts = searchParams.getAll('accounts[]');

  const subcategoryItems: FilterItemType[] = subcategories.map((subcategory) => {
    return {
      id: subcategory.id.toString(),
      label: subcategory.name,
      sublabel: null
    }
  });

  const accountItems: FilterItemType[] = accounts.map((account) => {
    return {
      id: account.id.toString(),
      label: account.name,
      sublabel: getUser(account.userId)?.name || ''
    }
  });

  return (
    <div className="flex flex-col items-center h-full w-full">
      <span className="text-xl">Filters</span>
      <FilterSelector
        title="Subcategory"
        items={subcategoryItems}
        selectedItems={selectedSubcategories}
        onItemClick={handleSubcategoryClick}
      />
      <FilterSelector
        title="Account"
        items={accountItems}
        selectedItems={selectedAccounts}
        onItemClick={handleAccountClick}
      />
    </div>
  )
}