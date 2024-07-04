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
  a1 = u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Freedom') do |a|
      a.bank_name = "Chase"
      a.name = "Freedom"
      a.account_type = "credit card"
    end
  a2 = u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Amazon') do |a|
      a.bank_name = "Chase"
      a.name = "Amazon"
      a.account_type = "credit card"
    end
  a3 = u1.accounts
    .find_or_create_by(bank_name: "Schwab", name: "Checking") do |a|
      a.bank_name = "Schwab"
      a.name = "Checking"
      a.account_type = "checking"
    end
  u1.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'United') do |a|
      a.bank_name = "Chase"
      a.name = "United"
      a.account_type = "credit card"
    end
  u1.accounts
    .find_or_create_by(bank_name: 'Capital One', name: 'Quicksilver') do |a|
      a.bank_name = "Capital One"
      a.name = "Quicksilver"
      a.account_type = "credit card"
    end
  u2.accounts
    .find_or_create_by(bank_name: 'Chase', name: 'Freedom') do |a|
      a.bank_name = "Chase"
      a.name = "Freedom"
      a.account_type = "credit card"
    end

  # Create Statements
  a1.statements
    .find_or_create_by(statement_date: Date.new(2024,5,1)) do |s|
      s.statement_date = Date.new(2024,5,1)
      s.statement_balance = 14.22
    end
  a1.statements
    .find_or_create_by(statement_date: Date.new(2024,6,1)) do |s|
      s.statement_date = Date.new(2024,6,1)
      s.statement_balance = 11.22
    end
  a2.statements
    .find_or_create_by(statement_date: Date.new(2024,5,1)) do |s|
      s.statement_date = Date.new(2024,5,1)
      s.statement_balance = 10.22
    end
  a2.statements
    .find_or_create_by(statement_date: Date.new(2024,6,1)) do |s|
      s.statement_date = Date.new(2024,6,1)
      s.statement_balance = 16.22
    end
  a3.statements
    .find_or_create_by(statement_date: Date.new(2024,6,1)) do |s|
      s.statement_date = Date.new(2024,6,1)
      s.statement_balance = nil
    end
end
