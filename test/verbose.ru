require 'rack'

app = lambda { |env|
  [200, {'Content-Type'=>'text/plain'}, ['BANG!']] }

use Rack::CommonLogger, $logger
run app
