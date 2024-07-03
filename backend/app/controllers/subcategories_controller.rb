class SubcategoriesController < ApplicationController
  before_action :set_subcategory, only: %i[ update destroy ]

  # POST /subcategories
  def create
    @subcategory = Subcategory.new(subcategory_params)

    if @subcategory.save
      render json: @subcategory, status: :created, location: @subcategory
    else
      render json: @subcategory.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subcategories/1
  def update
    if @subcategory.update(subcategory_params)
      render json: @subcategory
    else
      render json: @subcategory.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subcategories/1
  def destroy
    @subcategory.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subcategory
      @subcategory = Subcategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subcategory_params
      params.require(:subcategory).permit(:name, :category_id)
    end
end
