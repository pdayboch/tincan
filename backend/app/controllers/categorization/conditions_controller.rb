class Categorization::ConditionsController < ApplicationController
  before_action :set_condition, only: %i[ update destroy ]

  # GET /categorization/conditions
  def index
    data = CategorizationCondition.all
      .select(
        :id,
        :categorization_rule_id,
        :transaction_field,
        :match_type,
        :match_value
      )

    render json: data
  end

  # POST /categorization/conditions
  def create
    condition = CategorizationCondition.new(condition_params)
    if condition.errors.empty? && condition.save
      render json: condition, status: :created, location: condition
    else
      raise UnprocessableEntityError.new(condition.errors)
    end
  end

  # PUT categorization/conditions/1
  def update
    if @condition.update(condition_params)
      render json: @condition
    else
      raise UnprocessableEntityError.new(@condition.errors)
    end
  end

  # DELETE categorization/conditions/1
  def destroy
    @condition.destroy!
  end

  private

  def set_condition
    @condition = CategorizationCondition.find(params[:id])
  end

  def condition_params
    params.permit(
      :categorization_rule_id,
      :transaction_field,
      :match_type,
      :match_value
    )
  end
end
