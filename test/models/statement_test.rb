# frozen_string_literal: true

# == Schema Information
#
# Table name: statements
#
#  id                :bigint           not null, primary key
#  statement_date    :date
#  account_id        :bigint           not null
#  statement_balance :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  pdf_file_path     :text
#
require 'test_helper'

class StatementTest < ActiveSupport::TestCase
end
