# frozen_string_literal: true

module TransactionServices
  class CreateSplit
    class SplitAmountExceedsOriginalError < StandardError; end
    class SplitAmountSignMismatchError < StandardError; end

    def initialize(original_transaction, split_params)
      @original_transaction = original_transaction
      @split_params = split_params
      @splits = []

      raise ArgumentError, 'Original transaction cannot be nil' if @original_transaction.nil?

      @total_split_amount = calculate_split_amount
    end

    def call
      validate_split_amount_signs!
      validate_split_amounts!

      ActiveRecord::Base.transaction do
        create_splits
        adjust_original_amount
        update_original_has_splits_flag
      end

      {
        original: TransactionSerializer.new(@original_transaction).as_json,
        splits: serialized_splits
      }
    end

    private

    def validate_split_amount_signs!
      original_sign = @original_transaction.amount <=> 0
      all_signs_match = @split_params.all? { |split| (split[:amount].to_d <=> 0) == original_sign }

      return if all_signs_match

      raise SplitAmountSignMismatchError, 'amounts must match the sign of the original transaction amount'
    end

    def validate_split_amounts!
      return unless @total_split_amount.abs > @original_transaction.amount.abs

      raise SplitAmountExceedsOriginalError, 'total amount cannot exceed the original transaction amount'
    end

    def calculate_split_amount
      @split_params.sum { |split| split[:amount].to_d }
    end

    def create_splits
      @split_params.each do |split|
        @splits << Transaction.create!(
          split_from_id: @original_transaction.id,
          transaction_date: split[:transaction_date] || @original_transaction.transaction_date,
          amount: split[:amount],
          description: split[:description],
          subcategory_id: split[:subcategory_id],
          notes: split[:notes],
          account_id: @original_transaction.account_id
        )
      end
    end

    def adjust_original_amount
      @original_transaction.update!(amount: @original_transaction.amount - @total_split_amount)
    end

    def update_original_has_splits_flag
      @original_transaction.update!(has_splits: true)
    end

    def serialized_splits
      @splits.map { |split| TransactionSerializer.new(split).as_json }
    end
  end
end
