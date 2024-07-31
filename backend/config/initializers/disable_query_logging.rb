if Rails.env.development?
  ActiveRecord::Base.logger.level = Logger::INFO
end
