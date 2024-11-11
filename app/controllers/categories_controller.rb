# frozen_string_literal: true

class CategoriesController < ApplicationController
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
  rescue ArgumentError
    raise UnprocessableEntityError, { category_type: ["'#{params[:category_type]}' is invalid"] }
  end

  # PUT /categories/1
  def update
    category = Category.find(params[:id])
    raise UnprocessableEntityError, category.errors unless category.update(category_params)

    render json: category
  rescue ArgumentError
    raise UnprocessableEntityError, { category_type: ["'#{params[:category_type]}' is invalid"] }
  end

  # DELETE /categories/1
  def destroy
    category = Category.find(params[:id])
    category.destroy!
  rescue ActiveRecord::DeleteRestrictionError
    message = 'Cannot delete a category that has transactions associated with it'
    raise BadRequestError.new({ category: [message] })
  end

  private

  def category_params
    params.permit(:name, :category_type)
  end
end
