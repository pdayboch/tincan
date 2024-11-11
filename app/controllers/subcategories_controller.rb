# frozen_string_literal: true

class SubcategoriesController < ApplicationController
  before_action :set_subcategory, only: %i[update destroy]

  # POST /subcategories
  def create
    subcategory = Subcategory.new(subcategory_params)

    raise UnprocessableEntityError, subcategory.errors unless subcategory.save

    render json: subcategory, status: :created, location: subcategory
  end

  # PATCH/PUT /subcategories/1
  def update
    raise UnprocessableEntityError, @subcategory.errors unless @subcategory.update(subcategory_params)

    render json: @subcategory
  end

  # DELETE /subcategories/1
  def destroy
    @subcategory.destroy!
  rescue ActiveRecord::DeleteRestrictionError
    message = 'Cannot delete a subcategory that has transactions associated with it'
    raise BadRequestError.new({ subcategory: [message] })
  end

  private

  def set_subcategory
    @subcategory = Subcategory.find(params[:id])
  end

  def subcategory_params
    params.permit(:name, :category_id)
  end
end
