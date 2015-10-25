
module RackActiveJobSample
  UnauthorizedError = Class.new(StandardError)

  class Server
    def call(env)
      if env['REQUEST_PATH'] == '/api/v2/encueue'
        if env['REQUEST_METHOD'] == 'POST'
          require 'redis'
          r = Redis.new
          unless r.sismember('authorization:test', env['HTTP_AUTHORIZATION'])
            fail UnauthorizedError
          end
          r = env.dup
          r.delete('rack.errors')
          r.delete('puma.socket')
          r.delete('rack.hijack')
          r.delete('rack.tempfiles')
          body = r.delete('rack.input')
          body = body ? body.read : ''
          RackActiveJobSample::Worker.perform_later(request: r, body: body)
          return [
            202,
            {
              'Content-Type' => 'text/plain'
            },
            [ 'Accepted...' ]
          ]
        end
      end
      return [ 404, { 'Content-Type' => 'text/plain' }, [ 'Not Found' ] ]
    rescue UnauthorizedError
      [ 401, { 'Content-Type' => 'text/plain' }, [ 'Unauthorized Error' ] ]
    rescue => e
      p e
    end
  end
end
