module Shotgun
  # Responds to requests for /favicon.ico with a content free 404 and caching
  # headers.
  class SkipFavicon < Struct.new(:app)
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        [404, {
          'Content-Type'  => 'image/png',
          'Cache-Control' => 'public, max-age=100000000000'
        }, []]
      else
        app.call(env)
      end
    end
  end
end
