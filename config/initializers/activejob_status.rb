# frozen_string_literal: true

if Rails.env.development?
  ActiveJob::Status.store = :redis_cache_store,
                            { url: 'redis://localhost:6379/0' }
  ActiveJob::Status.options = { expires_in: 1.hour.to_i }
elsif Rails.env.test?
  ActiveJob::Status.store = :redis_cache_store,
                            { url: 'redis://localhost:6379/1' }
  ActiveJob::Status.options = { expires_in: 5.minutes.to_i }
elsif Rails.env.production?
  ActiveJob::Status.store = :redis_cache_store,
                            { url: ENV['REDIS_URL'] || 'redis://localhost:6379/2' }
  ActiveJob::Status.options = { expires_in: 30.days.to_i }
end
