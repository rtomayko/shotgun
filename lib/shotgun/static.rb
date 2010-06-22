require 'rack/file'

module Shotgun
  # Serves static files out of the specified directory.
  class Static
    def initialize(app, public_dir='./public')
      @file = Rack::File.new(public_dir)
      @app = app
    end

    def call(env)
      status, headers, body = @file.call(env)
      if status > 400
        @app.call(env)
      else
        [status, headers, body]
      end
    end
  end
end
