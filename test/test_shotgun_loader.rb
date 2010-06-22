require 'test/unit'
require 'rack/mock'
require 'shotgun'

class ShotgunLoaderTest < Test::Unit::TestCase
  def rackup_file(name)
    "#{File.dirname(__FILE__)}/#{name}"
  end

  def test_knows_the_rackup_file
    file = rackup_file('test.ru')
    shotgun = Shotgun::Loader.new(file)
    assert_equal file, shotgun.rackup_file
  end

  def test_processes_requests
    file = rackup_file('test.ru')
    shotgun = Shotgun::Loader.new(file)
    request = Rack::MockRequest.new(shotgun)
    res = request.get("/")
    assert_equal 200, res.status
    assert_equal "BANG!", res.body
    assert_equal "text/plain", res.headers['Content-Type']
  end

  def test_processes_large_requests
    file = rackup_file('big.ru')
    shotgun = Shotgun::Loader.new(file)
    request = Rack::MockRequest.new(shotgun)
    res = request.get("/")
    assert_equal 200, res.status
    assert res.body =~ %r|<pre>(?:.{1023}\n){1024}</pre>|,
      "body of size #{res.body.size} does not match expected output"
  end
end
