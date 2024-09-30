# frozen_string_literal: true

module Categorization
  class RulesController < ApplicationController
    before_action :set_rule, only: %i[update destroy]

    # GET /categorization/rules
    def index
      render json: CategorizationRuleDataEntity.new.data
    end

    # POST /categorization/rules
    def create
      rule = nil
      CategorizationRule.transaction do
        rule = create_rule
        create_conditions!(rule, rule_params[:conditions]) if rule_params.key?(:conditions)
      end

      render json: rule, status: :created, location: rule
    rescue ActiveRecord::RecordInvalid => e
      raise UnprocessableEntityError, e.record.errors
    end

    # PUT categorization/rules/1
    def update
      CategorizationRule.transaction do
        update_rule_attributes

        handle_conditions if rule_params.key?(:conditions)
      end

      render json: @rule
    rescue ActiveRecord::RecordInvalid => e
      raise UnprocessableEntityError, e.record.errors
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
      check_for_category_id!

      params.permit(
        :subcategory_id,
        conditions: %i[transaction_field match_type match_value]
      )
    end

    def check_for_category_id!
      return if params[:category_id].blank?

      message = 'parameter is not accepted. Please set the subcategoryId, ' \
                'and the category will be inferred automatically.'
      error = {
        category_id: [message]
      }
      raise UnprocessableEntityError, error
    end

    def create_rule
      rule = CategorizationRule.new(rule_params.except(:conditions))
      raise UnprocessableEntityError, rule.errors unless rule.save

      rule
    end

    def update_rule_attributes
      update_params = rule_params.except(:conditions)
      raise UnprocessableEntityError, @rule.errors unless @rule.update(update_params)
    end

    def handle_conditions
      @rule.categorization_conditions.destroy_all
      create_conditions!(@rule, rule_params[:conditions]) if rule_params[:conditions].present?
    end

    def create_conditions!(rule, conditions)
      conditions.each do |condition_params|
        rule.categorization_conditions.create!(condition_params)
      end
    end
  end
end
