# Default Categories
["Food",
"Gifts & Donations",
"Income",
"Transfer",
"Entertainment",
"Home",
"Auto & Transport",
"Bills & Utilities",
"Travel",
"Shopping",
"Health & Fitness",
"Miscellaneous",
"Fees & Charges",
"Personal Care",
"Investments",
"Taxes",
"Business Services"].each do |category_name|
  Category.find_or_create_by!(name: category_name)
end
