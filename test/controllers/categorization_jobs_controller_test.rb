# frozen_string_literal: true

require 'test_helper'

class CategorizationJobsControllerTest < ActionDispatch::IntegrationTest
  test 'should create job and return job_id' do
    assert_enqueued_with(job: CategorizeTransactionsJob) do
      post categorization_jobs_url
    end

    assert_response :accepted
    assert_includes response.body, 'job_id'
  end

  test 'should return job status when job exists' do
    job = CategorizeTransactionsJob.perform_later
    perform_enqueued_jobs

    get status_categorization_job_url(job.job_id)

    assert_response :ok
    json_response = response.parsed_body
    assert_equal job.job_id, json_response['job_id']
    assert_includes json_response.keys, 'status'
    assert_includes json_response.keys, 'progress'
  end

  # Test for job status when the job ID does not exist
  test 'should return 404 when job not found' do
    get status_categorization_job_url('non-existent-job-id')

    assert_response :not_found
    json_response = response.parsed_body
    assert_equal 'Job not found', json_response['error']
  end
end
