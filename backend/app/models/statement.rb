# == Schema Information
#
# Table name: statements
#
#  id                :bigint           not null, primary key
#  statement_date    :date
#  account_id        :bigint           not null
#  statement_balance :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Statement < ApplicationRecord
  belongs_to :account
  has_many :transactions, dependent: :nullify
end
