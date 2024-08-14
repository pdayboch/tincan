class SupportedAccountsController < ApplicationController
  def index
    render json: SupportedAccountsEntity.new.get_data
  end
end
