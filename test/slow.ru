class SlowResponse
  def call(env)
    [200, {'Content-Type'=>'text/html'}, self]
  end

  def each
    yield "<pre>"
    10.times do
      yield(('.' * 10) + "\n")
      sleep 0.5
    end
    yield "</pre>"
  end
end

run SlowResponse.new
