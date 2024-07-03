# Default Categories and Subcategories
default_categories = {
  "Food" => ["Alcohol & Bars", "Coffee Shops", "Fast Food", "Food Delivery", "Groceries", "Restaurants"],
  "Gifts & Donations" => ["Parents", "Gift", "Donation"],
  "Income" => ["Paycheck", "Dividend", "Interest Income", "Rebates"],
  "Transfer" => ["Credit Card Payment"],
  "Entertainment" => ["Music", "Newspapers & Magazines", "Music", "Games","Arts", "Movies & DVDs", "Outdoors"],
  "Home" => ["Rent & Mortgage", "Furnishings", "Home Improvement"],
  "Auto & Transport" => ["Gas & Fuel", "Public Transportation", "Tolls", "Parking", "Ride Share", "Service & Auto Parts", "Auto Payment", "Auto Insurance"],
  "Bills & Utilities" => ["Internet", "Mobile Phone", "Utilities", "Television"],
  "Travel" => ["Rental Car & Taxi", "Vacation", "Air Travel", "Hotel", "Train Travel", "Ferry Travel"],
  "Shopping" => ["Books", "Clothing", "Electronics & Software", "Pet Food & Supplies", "Shopping", "Sporting Goods"],
  "Health & Fitness" => ["Dentist", "Doctor", "Gym", "Pharmacy", "Sports"],
  "Miscellaneous" => ["Cash & ATM"],
  "Fees & Charges" => ["ATM Fee", "Service Fee"],
  "Personal Care" => ["Laundry", "Spa & Massage", "Hair"],
  "Investments" => ["Buy", "Sell"],
  "Taxes" => ["Federal Tax", "State Tax", "Tax Prep"],
  "Business Services" => ["Shipping"]
}

default_categories.each do |category, subcategories|
  c = Category.find_or_create_by!(name: category)
  subcategories.each do |subcategory|
    c.subcategories.find_or_create_by!(name: subcategory)
  end
end

if Rails.env.development?
  # Create Users
  User.find_or_create_by(email: 'philip245@gmail.com') do |u|
    u.name = "Phil"
    u.email = "philip245@gmail.com"
    u.password = "test1234"
  end
  User.find_or_create_by(email: 'krvani89@gmail.com') do |u|
    u.name = "Kate"
    u.email = "krvani89@gmail.com"
    u.password = "test1234"
  end
end
