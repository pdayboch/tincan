# frozen_string_literal: true

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
class AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :deletable

  attribute :bankName do
    object.bank_name
  end

  attribute :accountType do
    object.account_type
  end

  attribute :userId do
    object.user_id
  end

  attribute :statementDirectory do
    object.statement_directory
  end
end
