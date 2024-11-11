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
class Account < ApplicationRecord
  belongs_to :user
  has_many :statements, dependent: :destroy
  has_many :transactions, dependent: :destroy

  before_destroy :check_deletable

  scope :active, -> { where(active: true) }

  def statement_parser(file_path)
    "StatementParser::#{parser_class}".constantize.new(file_path) if parser_class.present?
  end

  private

  def check_deletable
    return if deletable

    errors.add(:base, "The #{name} account cannot be deleted.")
    throw(:abort)
  end
end
