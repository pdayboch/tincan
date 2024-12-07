# frozen_string_literal: true

module TransactionServices
  class SyncSplits
    class SplitAmountExceedsOriginalError < StandardError; end
    class SplitAmountSignMismatchError < StandardError; end
    class SplitNotFoundError < StandardError; end
    class ZeroAmountSplitError < StandardError; end

    def initialize(original_transaction, split_params)
      @original_transaction = original_transaction
      @split_params = format_split_params(split_params)

      raise ArgumentError, 'Original transaction cannot be nil' if @original_transaction.nil?

      @total_split_amount = calculate_split_amount
    end

    def call
      @existing_splits = @original_transaction.splits.pluck(:id, :amount).to_h.transform_keys(&:to_s)

      ActiveRecord::Base.transaction do
        reset_original_amount
        validate!
        process_splits
        adjust_original_amount
        update_original_has_splits_flag
        @original_transaction.save!
      end

      TransactionSplitDataEntity.new(@original_transaction).data
    end

    private

    def format_split_params(params)
      @split_params = params.map do |split|
        split[:id] = split[:id].to_s if split[:id].present?
        split
      end
    end

    def reset_original_amount
      current_split_total = @existing_splits.values.sum
      @original_transaction.amount += current_split_total
    end

    def validate!
      validate_split_ids!
      validate_split_amount_signs!
      validate_split_data_amounts!
      validate_no_zero_amounts!
    end

    def validate_split_ids!
      request_split_ids = @split_params.filter_map { |split| split[:id] }
      existing_split_ids = @existing_splits.keys
      invalid_ids = request_split_ids - existing_split_ids
      return if invalid_ids.empty?

      raise SplitNotFoundError, "ID(s) #{invalid_ids.join(', ')} not found for original transaction"
    end

    def validate_split_amount_signs!
      original_sign = @original_transaction.amount <=> 0
      return if @split_params
                # ignore zero amounts so validate_no_zero_amounts! correctly detects them
                .reject { |split| split[:amount].to_d.zero? }
                .all? { |split| (split[:amount].to_d <=> 0) == original_sign }

      raise SplitAmountSignMismatchError, 'amounts must match the sign of the original transaction amount'
    end

    def validate_split_data_amounts!
      return if @total_split_amount.abs <= @original_transaction.amount.abs

      raise SplitAmountExceedsOriginalError, 'total amount cannot exceed the original transaction amount'
    end

    def validate_no_zero_amounts!
      return unless @split_params.any? { |split| split[:amount].to_d.zero? }

      raise ZeroAmountSplitError, 'cannot have a zero amount'
    end

    def calculate_split_amount
      @split_params.sum { |split| split[:amount].to_d }
    end

    def process_splits
      @split_params.each do |split_data|
        if split_data[:id]
          update_split(split_data)
        else
          create_split(split_data)
        end
      end

      destroy_remaining_splits
    end

    def update_split(split_data)
      @existing_splits.delete(split_data[:id])
      @original_transaction.splits.find_by(id: split_data[:id]).update!(split_data)
    end

    def create_split(split_data)
      @original_transaction.splits.create!(
        transaction_date: split_data[:transaction_date] || @original_transaction.transaction_date,
        amount: split_data[:amount],
        description: split_data[:description],
        subcategory_id: split_data[:subcategory_id],
        notes: split_data[:notes],
        account_id: @original_transaction.account_id
      )
    end

    def destroy_remaining_splits
      @original_transaction.splits.where(id: @existing_splits.keys).destroy_all
    end

    def adjust_original_amount
      @original_transaction.amount -= @total_split_amount
    end

    def update_original_has_splits_flag
      @original_transaction.has_splits = @split_params.any?
    end
  end
end
