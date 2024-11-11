# frozen_string_literal: true

class CategorizationJobsController < ApplicationController
  def create
    job = CategorizeTransactionsJob.perform_later
    render json: { job_id: job.job_id }, status: :accepted
  end

  def status
    job = fetch_job_status(params[:id])

    return render json: { error: 'Job not found' }, status: :not_found if job.nil?

    render json: { job_id: job.job_id, status: job.status, progress: job.progress }, status: :ok
  end

  private

  #  ActiveJob::Status will always return a job
  #  even if it doesn't exist. This helper method
  #  returns nil if the 'status' key is missing
  #  which indicates the job doesn't exist.
  def fetch_job_status(job_id)
    job = ActiveJob::Status.get(job_id)
    job if job && job[:status]
  end
end
