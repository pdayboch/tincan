# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  bank_name    :string
#  name         :string
#  account_type :string
#  active       :boolean
#  user_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
