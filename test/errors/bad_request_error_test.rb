# frozen_string_literal: true

require 'test_helper'

class BadRequestErrorTest < ActiveSupport::TestCase
  test 'initialize with errors' do
    errors = {
      per_page: ['perPage must be less than or equal to 1000'],
      unknown_param: ['unknownParam is not recognized']
    }

    exception = BadRequestError.new(errors)

    expected_errors = [
      { field: 'perPage', message: 'perPage must be less than or equal to 1000' },
      { field: 'unknownParam', message: 'unknownParam is not recognized' }
    ]

    assert_equal 'Bad Request', exception.message
    assert_equal expected_errors, exception.errors
  end
end
