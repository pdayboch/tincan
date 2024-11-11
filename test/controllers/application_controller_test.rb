# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  # Dummy controller for testing rescue behavior
  class TestController < ApplicationController
    def unprocessable_entity
      raise UnprocessableEntityError.new(subcategoryId: ["can't be blank"])
    end

    def bad_request
      raise BadRequestError.new(perPage: ['perPage must be less than or equal to 500'])
    end
  end

  test 'rescues unprocessable_entity error' do
    with_routing do |set|
      set.draw do
        get 'unprocessable_entity',
            to: 'application_controller_test/test#unprocessable_entity'
      end

      # Simulate a request that raises UnprocessableEntityError
      get '/unprocessable_entity'

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
      assert_equal expected_response, response.parsed_body
    end
  end

  test 'rescues bad_request error' do
    with_routing do |set|
      set.draw do
        get 'bad_request',
            to: 'application_controller_test/test#bad_request'
      end

      # Simulate a request that raises BadRequestError
      get '/bad_request'

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
      assert_equal expected_response, response.parsed_body
    end
  end
end
