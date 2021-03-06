require 'time'
require 'sidekiq'
require 'active_job'

require 'rack_active_job_sample/version'
require 'rack_active_job_sample/server'
require 'rack_active_job_sample/worker'

require 'rack'
require 'puma'

ActiveJob::Base.queue_adapter = :sidekiq

module RackActiveJobSample
end
