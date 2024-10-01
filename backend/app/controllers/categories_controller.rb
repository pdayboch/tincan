# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :set_category, only: %i[update destroy]

  # GET /categories
  def index
    data = CategoryDataEntity.new.data

    render json: data
  end

  # POST /categories
  def create
    category = Category.new(category_params)

    raise UnprocessableEntityError, category.errors unless category.save

    render json: category, status: :created, location: category
  end

  # PUT /categories/1
  def update
    raise UnprocessableEntityError, @category.errors unless @category.update(category_params)

    render json: @category
  end

  # DELETE /categories/1
  def destroy
    @category.destroy!
  rescue ActiveRecord::DeleteRestrictionError
    message = 'Cannot delete a category that has transactions associated with it'
    raise BadRequestError.new({ category: [message] })
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.permit(:name)
  end
end
