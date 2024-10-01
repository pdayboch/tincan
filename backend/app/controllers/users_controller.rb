# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[update destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # POST /users
  def create
    user = User.new(user_params)
    raise UnprocessableEntityError, user.errors unless user.save

    render json: user, status: :created, location: user
  end

  # PATCH/PUT /users/1
  def update
    raise UnprocessableEntityError, @user.errors unless @user.update(user_params)

    render json: @user
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:name, :email, :password)
  end
end
