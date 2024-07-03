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
  u1 = User.find_or_create_by(email: 'philip245@gmail.com') do |u|
    u.name = "Phil"
    u.email = "philip245@gmail.com"
    u.password = "test1234"
  end
  u2 = User.find_or_create_by(email: 'krvani89@gmail.com') do |u|
    u.name = "Kate"
    u.email = "krvani89@gmail.com"
    u.password = "test1234"
  end

  # Create Accounts
  u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Freedom') do |a|
      a.bank_name = "Chase"
      a.name = "Freedom"
      a.account_type = "credit card"
      a.active = true
    end
  u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Amazon') do |a|
      a.bank_name = "Chase"
      a.name = "Amazon"
      a.account_type = "credit card"
      a.active = true
    end
  u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'United') do |a|
      a.bank_name = "Chase"
      a.name = "United"
      a.account_type = "credit card"
      a.active = true
    end
  u1.accounts
    .find_or_create_by(bank_name: 'Capital One', name: 'Quicksilver') do |a|
      a.bank_name = "Capital One"
      a.name = "Quicksilver"
      a.account_type = "credit card"
      a.active = true
    end
  u2.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Freedom') do |a|
      a.bank_name = "Chase"
      a.name = "Freedom"
      a.account_type = "credit card"
      a.active = true
    end
end
