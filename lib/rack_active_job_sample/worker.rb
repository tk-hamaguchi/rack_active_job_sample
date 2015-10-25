require 'rack'

class RackActiveJobSample::Worker < ActiveJob::Base
  queue_as :event

  def perform(request:, body:)
    p 'perform'
    p ::Rack::Request.new(request)
    p body
  end
end
