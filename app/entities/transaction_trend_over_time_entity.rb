# frozen_string_literal: true

class TransactionTrendOverTimeEntity
  TYPE_VALUES = %w[spend income].freeze
  GROUP_BY_VALUES = %w[day week month year].freeze

  def initialize(start_date, end_date, params = {})
    validate_date_range!(start_date, end_date)
    validate_params!(params)

    @start_date = start_date
    @end_date = end_date
    @type = params[:type] || 'spend'
    @group_by = params[:group_by] || 'month'
  end

  def data
    base_query
      .group_by_period(
        @group_by,
        :transaction_date,
        range: date_range,
        expand_range: true,
        default_value: 0.0
      )
      .sum(:amount)
      .map { |date, amount| { date: date.to_s, amount: amount.to_f } }
  end

  private

  def date_range
    @start_date..@end_date
  end

  def base_query
    Transaction.joins(:category)
               .where(categories: { category_type: @type })
               .where(transaction_date: date_range)
  end

  def validate_date_range!(start_date, end_date)
    return if start_date < end_date

    raise BadRequestError.new(end_date: ['endDate must be after startDate'])
  end

  def validate_params!(params)
    validate_type!(params)
    validate_group_by!(params)
  end

  def validate_type!(params)
    return unless params[:type] && TYPE_VALUES.exclude?(params[:type])

    raise BadRequestError.new(type: ["type must be one of #{TYPE_VALUES.join(', ')}"])
  end

  def validate_group_by!(params)
    return unless params[:group_by] && GROUP_BY_VALUES.exclude?(params[:group_by])

    raise BadRequestError.new(group_by: ["groupBy must be one of #{GROUP_BY_VALUES.join(', ')}"])
  end
end
