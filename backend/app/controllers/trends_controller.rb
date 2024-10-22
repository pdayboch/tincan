# frozen_string_literal: true

class TrendsController < ApplicationController
  # GET /trends/overTime
  # Look at trends over time (x axis is always time)
  def over_time
    validate_date_params!

    start_date = over_time_params.delete(:start_date).to_date
    end_date = over_time_params.delete(:end_date).to_date
    data = TransactionTrendOverTimeEntity.new(
      start_date,
      end_date,
      over_time_params
    ).data

    render json: data
  end

  private

  def validate_date_params!
    raise BadRequestError.new(start_date: ['startDate is required']) unless over_time_params[:start_date]
    raise BadRequestError.new(end_date: ['endDate is required']) unless over_time_params[:end_date]
  end

  def over_time_params
    params.permit(
      :start_date,
      :end_date,
      :type,
      :group_by
    )
  end
end
