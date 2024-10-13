# frozen_string_literal: true

# == Schema Information
#
# Table name: categorization_conditions
#
#  id                     :bigint           not null, primary key
#  categorization_rule_id :bigint           not null
#  transaction_field      :string           not null
#  match_type             :string           not null
#  match_value            :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class CategorizationCondition < ApplicationRecord
  belongs_to :categorization_rule

  # Define the valid match types for each transaction field
  MATCH_TYPES_FOR_FIELDS = {
    'description' => %w[starts_with ends_with exactly],
    'amount' => %w[greater_than less_than exactly],
    'date' => %w[greater_than less_than exactly],
    'account' => %w[exactly]
  }.freeze

  validate :transaction_field_valid
  validate :match_type_valid
  validates :match_value, presence: true
  validate :match_value_valid_for_date_field

  DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

  def matches?(transaction)
    case transaction_field
    when 'description' then match_description?(transaction.description)
    when 'amount' then match_amount?(transaction.amount)
    when 'date' then match_date?(transaction.transaction_date)
    when 'account' then match_account?(transaction.account_id)
    end
  end

  private

  def match_description?(description)
    case match_type
    when 'starts_with' then description.starts_with?(match_value)
    when 'ends_with' then description.ends_with?(match_value)
    when 'exactly' then description == match_value
    end
  end

  def match_amount?(amount)
    case match_type
    when 'greater_than' then amount > match_value.to_f
    when 'less_than' then amount < match_value.to_f
    when 'exactly' then (amount * 100.to_i) == (match_value.to_f * 100).to_i
    end
  end

  def match_date?(date)
    case match_type
    when 'greater_than' then date > Date.parse(match_value)
    when 'less_than' then date < Date.parse(match_value)
    when 'exactly' then date == Date.parse(match_value)
    end
  end

  def match_account?(account_id)
    case match_type
    when 'exactly' then account_id == match_value.to_i
    end
  end

  def transaction_field_valid
    if transaction_field.blank?
      errors.add(:transaction_field, "can't be blank")
    elsif MATCH_TYPES_FOR_FIELDS.keys.exclude?(transaction_field)
      error_message = "#{transaction_field} is invalid. " \
                      "The options are: #{MATCH_TYPES_FOR_FIELDS.keys.join(', ')}"
      errors.add(:transaction_field, error_message)
    end
  end

  def match_type_valid
    if match_type.blank?
      errors.add(:match_type, "can't be blank")
    elsif MATCH_TYPES_FOR_FIELDS.keys.include?(transaction_field)
      # only check this is transaction_field is valid
      match_type_is_valid_for_transaction_field
    end
  end

  def match_type_is_valid_for_transaction_field
    valid_match_types = MATCH_TYPES_FOR_FIELDS[transaction_field]
    return if valid_match_types.include?(match_type)

    error_message = "is not valid for the field '#{transaction_field}'. " \
                    "Valid match types are: #{valid_match_types.join(', ')}"
    errors.add(:match_type, error_message)
  end

  def match_value_valid_for_date_field
    return unless transaction_field == 'date'

    unless match_value =~ DATE_REGEX
      errors.add(:match_value, "must be in the format 'YYYY-MM-DD' when the transaction_field is 'date'")
      return
    end

    begin
      Date.parse(match_value)
    rescue Date::Error => e
      errors.add(:match_value, e.message)
    end
  end
end
