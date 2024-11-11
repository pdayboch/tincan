# frozen_string_literal: true

class SupportedAccountsController < ApplicationController
  def index
    render json: SupportedAccountsEntity.new.data
  end
end
