# frozen_string_literal: true

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

  before_validation :apply_categorization_rule, on: :create
  before_validation :sync_category_with_subcategory,
                    if: -> { will_save_change_to_subcategory_id? }

  private

  # This searches through all categorization rules and applies the first matching rule
  def apply_categorization_rule
    matched_rule = CategorizationRule.all.find { |rule| rule.match?(self) }

    # If no rule matches, set to uncategorized
    return set_default_category_and_subcategory unless matched_rule

    self.category = matched_rule.category
    self.subcategory = matched_rule.subcategory
  end

  def set_default_category_and_subcategory
    self.subcategory ||= Subcategory.find_by(name: 'Uncategorized')
    self.category = self.subcategory.category
  end

  # Ensure that the category is in sync with the subcategory
  def sync_category_with_subcategory
    self.category = subcategory.category if subcategory
  end
end
