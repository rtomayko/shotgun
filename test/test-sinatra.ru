require 'sinatra'

set :logging, false

get '/' do
  puts 'hello world'
  "Hello World"
end

get '/boom' do
  fail 'boom'
end

run Sinatra::Application
