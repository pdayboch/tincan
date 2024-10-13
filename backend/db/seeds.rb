# Default Categories and Subcategories
default_categories = {
  'Food' => ['Alcohol & Bars', 'Coffee Shops', 'Fast Food', 'Food Delivery', 'Groceries', 'Restaurants'],
  'Gifts & Donations' => ['Parents', 'Gift', 'Donation'],
  'Income' => ['Paycheck', 'Dividend', 'Interest Income', 'Rebates'],
  'Transfer' => ['Credit Card Payment', 'Transfer'],
  'Entertainment' => ['Music', 'Newspapers & Magazines', 'Music', 'Games', 'Arts', 'Movies & DVDs', 'Outdoors'],
  'Home' => ['Rent & Mortgage', 'Furnishings', 'Home Improvement'],
  'Auto & Transport' => ['Gas & Fuel', 'Public Transportation', 'Tolls', 'Parking', 'Ride Share', 'Service & Auto Parts', 'Auto Payment', 'Auto Insurance'],
  'Bills & Utilities' => ['Internet', 'Mobile Phone', 'Utilities', 'Television'],
  'Travel' => ['Rental Car & Taxi', 'Vacation', 'Air Travel', 'Hotel', 'Train Travel', 'Ferry Travel'],
  'Shopping' => ['Books', 'Clothing', 'Electronics & Software', 'Pet Food & Supplies', 'Shopping', 'Sporting Goods'],
  'Health & Fitness' => ['Dentist', 'Doctor', 'Gym', 'Pharmacy', 'Sports'],
  'Miscellaneous' => ['Cash & ATM'],
  'Fees & Charges' => ['ATM Fee', 'Service Fee'],
  'Personal Care' => ['Laundry', 'Spa & Massage', 'Hair'],
  'Investments' => ['Buy', 'Sell'],
  'Taxes' => ['Federal Tax', 'State Tax', 'Tax Prep'],
  'Business Services' => ['Shipping'],
  'Uncategorized' => ['Uncategorized'],
}

default_categories.each do |category, subcategories|
  c = Category.find_or_create_by!(name: category)
  subcategories.each do |subcategory|
    c.subcategories.find_or_create_by!(name: subcategory)
  end
end

if Rails.env.development?
  # Create Users
  phil = User.find_or_create_by(email: 'philip245@gmail.com') do |u|
    u.name = 'Phil'
    u.email = 'philip245@gmail.com'
    u.password = 'test1234'
  end

  kate = User.find_or_create_by(email: 'krvani89@gmail.com') do |u|
    u.name = 'Kate'
    u.email = 'krvani89@gmail.com'
    u.password = 'test1234'
  end

  # Create Accounts
  phil.accounts.find_or_create_by(bank_name: 'Chase', name: 'Freedom Credit Card') do |a|
    a.bank_name = 'Chase'
    a.name = 'Freedom Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Credit Cards/Chase Freedom'
    a.parser_class = 'ChaseFreedomCreditCard'
  end

  phil.accounts.find_or_create_by(bank_name: 'Chase', name: 'Amazon Credit Card') do |a|
    a.bank_name = 'Chase'
    a.name = 'Amazon Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Credit Cards/Chase Amazon'
    a.parser_class = 'ChaseAmazonCreditCard'
  end

  phil.accounts.find_or_create_by(bank_name: 'Chase', name: 'United Credit Card') do |a|
    a.bank_name = 'Chase'
    a.name = 'United Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Credit Cards/Chase United'
  end

  phil.accounts.find_or_create_by(bank_name: 'Charles Schwab', name: 'Checking') do |a|
    a.bank_name = 'Charles Schwab'
    a.name = 'Checking'
    a.account_type = 'checking'
    a.statement_directory = 'Banks and Investments/Schwab Checking'
    a.parser_class = 'CharlesSchwabChecking'
  end

  phil.accounts.find_or_create_by(bank_name: 'Barclays', name: 'View Credit Card') do |a|
    a.bank_name = 'Barclays'
    a.name = 'View Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Credit Cards/Barclays View'
    a.parser_class = 'BarclaysViewCreditCard'
  end

  phil.accounts.find_or_create_by(bank_name: 'Capital One', name: 'Quicksilver Credit Card') do |a|
    a.bank_name = 'Capital One'
    a.name = 'Quicksilver Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Credit Cards/Capital One Quicksilver'
  end

  kate.accounts.find_or_create_by(bank_name: 'Chase', name: 'Freedom Credit Card') do |a|
    a.bank_name = 'Chase'
    a.name = 'Freedom Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Kate/Credit Cards/Chase Freedom'
    a.parser_class = 'ChaseFreedomCreditCard'
  end

  kate.accounts.find_or_create_by(bank_name: 'Chase', name: 'Amazon Credit Card') do |a|
    a.bank_name = 'Chase'
    a.name = 'Amazon Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Kate/Credit Cards/Chase Amazon'
    a.parser_class = 'ChaseAmazonCreditCard'
  end

  kate.accounts.find_or_create_by(bank_name: 'Wells Fargo', name: 'Autograph Credit Card') do |a|
    a.bank_name = 'Wells Fargo'
    a.name = 'Autograph Credit Card'
    a.account_type = 'credit card'
    a.statement_directory = 'Kate/Credit Cards/Wells Fargo Autograph'
    a.parser_class = 'ChaseFreedomCreditCard'
  end

  # Create categorization rules
  atm_subcategory = Subcategory.find_by(name: 'Cash & ATM')
  gym_subcategory = Subcategory.find_by(name: 'Gym')
  parents_subcategory = Subcategory.find_by(name: 'Parents')
  dividend_subcategory = Subcategory.find_by(name: 'Dividend')

  r1 = CategorizationRule.find_or_create_by(subcategory_id: atm_subcategory.id)
  r2 = CategorizationRule.find_or_create_by(subcategory_id: gym_subcategory.id)
  r3 = CategorizationRule.find_or_create_by(subcategory_id: parents_subcategory.id)
  CategorizationRule.find_or_create_by(subcategory_id: dividend_subcategory.id)

  r1.categorization_conditions.find_or_create_by(transaction_field: 'description') do |c|
    c.match_type = 'starts_with'
    c.match_value = 'ATM'
  end
  r1.categorization_conditions.find_or_create_by(transaction_field: 'amount') do |c|
    c.match_type = 'greater_than'
    c.match_value = '19.99'
  end

  r2.categorization_conditions.find_or_create_by(transaction_field: 'description') do |c|
    c.match_type = 'exactly'
    c.match_value = 'planet fitness'
  end

  r3.categorization_conditions.find_or_create_by(transaction_field: 'description') do |c|
    c.match_type = 'exactly'
    c.match_value = 'Venmo'
  end

  r3.categorization_conditions.find_or_create_by(transaction_field: 'amount') do |c|
    c.match_type = 'exactly'
    c.match_value = '250.00'
  end
end
