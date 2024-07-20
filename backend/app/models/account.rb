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
#
class Account < ApplicationRecord
  belongs_to :user
  has_many :statements, dependent: :destroy
  has_many :transactions, dependent: :destroy

  before_destroy :check_deletable

  private

  def check_deletable
    if !deletable
      errors.add(:base, "The #{name} account cannot be deleted.")
      throw(:abort) # Stop the destroy action from proceeding
    end
  end
end
