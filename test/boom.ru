require 'rack'

use Rack::Lock
run lambda { |env| fail 'boom' }
