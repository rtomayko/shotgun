require 'test/unit'
require 'rack/mock'
require 'shotgun'

class ShotgunStaticTest < Test::Unit::TestCase
  def setup
    @app = lambda { |env| [200,{'Content-Type'=>'text/plain'}, ['holla']] }
    @public = File.dirname(__FILE__)
  end

  def test_serving_files
    static = Shotgun::Static.new(@app, @public)
    request = Rack::MockRequest.new(static)
    res = request.get("/big.ru")
    assert_equal 200, res.status
    assert_equal File.size("#{@public}/big.ru"), res.body.size
  end

  def test_cascading_when_file_not_found
    static = Shotgun::Static.new(@app, @public)
    request = Rack::MockRequest.new(static)
    res = request.get("/does-not-exist")
    assert_equal 200, res.status
    assert_equal 'holla', res.body
  end
end
