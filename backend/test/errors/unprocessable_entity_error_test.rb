require 'test_helper'

class UnprocessableEntityErrorTest < ActiveSupport::TestCase
  def test_initialize_with_hash_errors
    hash_errors = {
      name: ['cannot be blank'],
      email: ['is invalid']
    }
    exception = UnprocessableEntityError.new(hash_errors)
    expected_errors = [
      { field: 'name', message: 'name cannot be blank' },
      { field: 'email', message: 'email is invalid' }
    ]

    assert_equal 'Unprocessable Entity', exception.message
    assert_equal expected_errors, exception.errors
  end

  def test_initialize_with_active_model_errors
    model = User.new
    model.errors.add(:name, 'cannot be blank')
    model.errors.add(:email, 'is invalid')
    active_model_errors = model.errors
    exception = UnprocessableEntityError.new(active_model_errors)
    expected_errors = [
      { field: 'name', message: 'name cannot be blank' },
      { field: 'email', message: 'email is invalid' }
    ]

    assert_equal 'Unprocessable Entity', exception.message
    assert_equal expected_errors, exception.errors
  end
end
