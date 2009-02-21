require 'bacon'
require 'shotgun'
require 'rack/mock'

test_dir = 

describe 'Shotgun' do
  rackup_file = "#{File.dirname(__FILE__)}/test.ru"
  shotgun = Shotgun.new(rackup_file)

  it "knows the rackup file" do
    shotgun.rackup_file.should.equal rackup_file
  end

  it "processes requests" do
    request = Rack::MockRequest.new(shotgun)
    res = request.get("/")
    res.status.should.equal 200
    res.body.should.equal "BANG!"
    res.headers['Content-Type'].should.equal 'text/plain'
  end
end
