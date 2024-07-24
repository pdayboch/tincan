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
class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :statement, optional: true
  belongs_to :category
  belongs_to :subcategory

  before_validation :set_default_category_and_subcategory

  private

  def set_default_category_and_subcategory
    self.subcategory ||= Subcategory.find_by(name: "Uncategorized")
    self.category = self.subcategory.category
  end
end
