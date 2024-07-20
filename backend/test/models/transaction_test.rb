# == Schema Information
#
# Table name: transactions
#
#  id                         :bigint           not null, primary key
#  transaction_date           :date             not null
#  amount                     :decimal(10, 2)   not null
#  description                :text
#  account_id                 :bigint           not null
#  statement_id               :bigint
#  category_id                :bigint           not null
#  subcategory_id             :bigint           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  notes                      :text
#  statement_description      :text
#  statement_transaction_date :date
#
require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
