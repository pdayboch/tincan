class Categorization::ConditionsController < ApplicationController
  before_action :set_condition, only: %i[ update destroy ]
  before_action :transform_params, only: %i[ create update ]

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
      render json: condition.errors, status: :unprocessable_entity
    end
  end

  # PUT categorization/conditions/1
  def update
    if @condition.update(condition_params)
      render json: @condition
    else
      render json: @condition.errors, status: :unprocessable_entity
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

  # Transform flat params to nested and camelCase to snake_case
  def transform_params
    condition_params = params.slice(
      :categorizationRuleId,
      :transactionField,
      :matchType,
      :matchValue
    )

    params[:condition] = condition_params.transform_keys { |key| key.to_s.underscore }
  end

  def condition_params
    params.require(:condition)
      .permit(
        :categorization_rule_id,
        :transaction_field,
        :match_type,
        :match_value
      )
  end
end
