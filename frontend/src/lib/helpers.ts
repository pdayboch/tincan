import { Category } from "./definitions";

// Helper function to format amount as dollar value
export const formatCurrency = (amount: number) => {
  const formattedAmount = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  }).format(Math.abs(amount));

  return amount < 0 ? `-${formattedAmount}` : `${formattedAmount}`;
};

export const formatDate = (dateString: string) => {
  const [year, month, day] = dateString.split('-');
  return `${month}-${day}-${year}`;
};

export function findSubcategoryId(
  categories: Category[],
  subcategoryName: string
): number | undefined {
  // Iterate through each category
  for (const category of categories) {
    // Iterate through each subcategory in the category
    for (const subcategory of category.subcategories) {
      // Check if the subcategory name matches
      if (subcategory.name === subcategoryName) {
        // Return the subcategory id as a string
        return subcategory.id;
      }
    }
  }

  return undefined;
}

export function findSubcategoryNameById(categories: Category[], id: number): string {
  // Iterate through each category
  for (const category of categories) {
    // Iterate through each subcategory in the category
    for (const subcategory of category.subcategories) {
      // Check if the subcategory id matches
      if (subcategory.id === id) {
        // Return the subcategory name
        return subcategory.name;
      }
    }
  }
  return '';
}