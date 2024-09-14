require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  # Dummy controller for testing rescue behavior
  class TestController < ApplicationController
    def unprocessable_entity_action
      raise UnprocessableEntityError.new(subcategoryId: ["can't be blank"])
    end

    def bad_request_action
      raise BadRequestError.new(perPage: ['perPage must be less than or equal to 500'])
    end
  end

  # Set up a dummy controller for testing
  tests TestController

  # Override the @routes to define custom routes for the test controller
  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'unprocessable_entity_action',
          to: 'application_controller_test/test#unprocessable_entity_action'
      get 'bad_request_action',
          to: 'application_controller_test/test#bad_request_action'
    end
  end

  def test_rescues_unprocessable_entity_error
    # Simulate a request that raises UnprocessableEntityError
    get :unprocessable_entity_action

    # Ensure the response is 422 Unprocessable Entity
    assert_response :unprocessable_entity

    # Check the JSON response contains the correct error format
    expected_response = {
      'errors' => [
        {
          'field' => 'subcategoryId',
          'message' => "subcategoryId can't be blank"
        }
      ]
    }
    assert_equal expected_response, JSON.parse(response.body)
  end

  def test_rescues_bad_request_error
    # Simulate a request that raises BadRequestError
    get :bad_request_action

    # Ensure the response is 400 Bad Request
    assert_response :bad_request

    # Check the JSON response contains the correct error format
    expected_response = {
      'errors' => [
        {
          'field' => 'perPage',
          'message' => 'perPage must be less than or equal to 500'
        }
      ]
    }
    assert_equal expected_response, JSON.parse(response.body)
  end
end
