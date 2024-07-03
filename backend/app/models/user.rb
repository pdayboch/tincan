# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  has_secure_password
  has_many :accounts, dependent: :destroy

  after_create :create_cash_account
  before_destroy :make_accounts_deletable,
    prepend: true # Ensures this executes before trying to destroy anthing.

  validates :email,
  presence: true,
  uniqueness: {
    case_sensitive: false,
    message: 'already exists'
  }

  private

  def create_cash_account
    accounts.create!(name: 'Cash', deletable: false)
  end

  def make_accounts_deletable
    accounts.update_all(deletable: true)
  end
end
