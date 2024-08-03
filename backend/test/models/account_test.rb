# == Schema Information
#
# Table name: accounts
#
#  id                  :bigint           not null, primary key
#  bank_name           :string
#  name                :string           not null
#  account_type        :string
#  active              :boolean          default(TRUE)
#  deletable           :boolean          default(TRUE)
#  user_id             :bigint           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  statement_directory :text
#  parser_class        :string
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test 'should not allow deletion of non-deletable accounts' do
    account = accounts(:non_deletable_account)
    assert_not account.deletable, 'Account is marked as deletable'

    # Attempt to delete the account and assert that destroy returns false
    assert_not account.destroy, 'Account was deleted dispite being non-deletable'

    # Reload the account from the database and assert that it still exists
    refute_nil Account.find_by(id: account.id), 'Account was deleted despite being non-deletable'
  end
end
