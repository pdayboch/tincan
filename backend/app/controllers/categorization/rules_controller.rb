class Categorization::RulesController < ApplicationController
  before_action :set_rule, only: %i[ update destroy ]

  # GET /categorization/rules
  def index
    data = CategorizationRule.all
      .select(
        :id,
        :category_id,
        :subcategory_id
      )

    render json: data
  end

  # POST /categorization/rules
  def create
    rule = CategorizationRule.new(rule_params)

    if rule.errors.empty? && rule.save
      render json: rule, status: :created, location: rule
    else
      raise UnprocessableEntityError.new(rule.errors)
    end
  end

  # PUT categorization/rules/1
  def update
    if @rule.update(rule_params)
      render json: @rule
    else
      raise UnprocessableEntityError.new(@rule.errors)
    end
  end

  # DELETE categorization/rules/1
  def destroy
    @rule.destroy!
  end

  private

  def set_rule
    @rule = CategorizationRule.find(params[:id])
  end

  def rule_params
    if params[:category_id].present?
      error = {
        category_id: ['parameter is not accepted. Please set the subcategoryId, and the category will be inferred automatically.']
      }
      raise UnprocessableEntityError.new(error)
    end

    params.permit(:subcategory_id)
  end
end
