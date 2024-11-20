# frozen_string_literal: true

module Transactions
  class SplitsController < ApplicationController
    # GET /transactions/:id/splits
    def show
      original_transaction = Transaction.find(params[:id])
      data = TransactionSplitDataEntity.new(original_transaction).data

      render json: data
    end

    # PATCH /transactions/:id/sync-splits
    def sync
      original_transaction = Transaction.find(params[:id])

      result = TransactionServices::SyncSplits.new(original_transaction, split_params).call

      render json: result, status: :ok
    rescue TransactionServices::SyncSplits::SplitNotFoundError => e
      error_msg = [{ field: 'splits', message: e.message }]
      render json: { errors: error_msg }, status: :not_found
    rescue TransactionServices::SyncSplits::SplitAmountExceedsOriginalError,
           TransactionServices::SyncSplits::SplitAmountSignMismatchError => e

      raise UnprocessableEntityError, { splits: [e.message] }
    rescue ActiveRecord::RecordInvalid => e
      raise UnprocessableEntityError, e.record.errors
    end

    private

    def split_params
      splits = params[:splits] || []
      splits.map do |split|
        split.permit(:id, :amount, :description, :notes, :subcategory_id, :transaction_date)
      end
    rescue NoMethodError
      message = 'Invalid format for splits parameter; Must be an array of objects.'
      raise BadRequestError, { splits: [message] }
    end
  end
end
