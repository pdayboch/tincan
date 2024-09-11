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

  validates :transaction_field,
    presence: true,
    inclusion: { in: MATCH_TYPES_FOR_FIELDS.keys }

  validates :match_type, presence: true
  validates :match_value, presence: true
  validate :match_type_is_valid_for_transaction_field,
    if: -> { MATCH_TYPES_FOR_FIELDS.keys.include?(transaction_field) }

  def match_type_is_valid_for_transaction_field
    valid_match_types = MATCH_TYPES_FOR_FIELDS[transaction_field]
    unless valid_match_types.include?(match_type)
      errors.add(:match_type, "is not valid for the field '#{transaction_field}` Valid match types are: #{valid_match_types.join(', ')}")
    end
  end

  def matches?(transaction)
    case transaction_field
    when 'description'
      case match_type
      when 'starts_with' then transaction.description.starts_with?(match_value)
      when 'ends_with' then transaction.description.ends_with?(match_value)
      when 'exactly' then transaction.description == match_value
      end
    when 'amount'
      case match_type
      when 'greater_than' then transaction.amount > match_value.to_f
      when 'less_than' then transaction.amount < match_value.to_f
      when 'exactly' then transaction.amount ==  match_value.to_f
      end
    when 'date'
      transaction_date = transaction.transaction_date
      case match_type
      when 'greater_than' then transaction_date > Date.parse(match_value)
      when 'less_than' then transaction_date < Date.parse(match_value)
      when 'exactly' then transaction_date == Date.parse(match_value)
      end
    when 'account'
      case match_type
      when 'exactly' then transaction.account_id == match_value.to_i
      end
    end
  end
end
