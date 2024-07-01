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
class Account < ApplicationRecord
  belongs_to :user
  has_many :statements
end
